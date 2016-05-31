#!/usr/bin/env bash
# ============================================ #
# ====          Liquid CLI v1.2.0         ==== #
# ====  By: Zack Warren, Spencer Merritt  ==== #
# ============================================ #

# ===================== #
# ==== Liquid Logo ==== #
# ===================== #

printf "this is a test";


function liquidCLI:logo(){
	printf "${YELLOW}
   __   _           _    __
  / /  (_)__  __ __(_)__/ /
 / /__/ / _ \/ // / / _  /
/____/_/\_  /\_,_/_/\_,_/
         /_/
${NC}
 WordPress Theme Installer
===========================\n";
}

# ============================= #
# ==== Liquid Info Command ==== #
# ============================= #

function liquidCLI:info() {
	liquidCLI:logo;
	printf "    Available Commands:\n";
	printf "===========================\n\n";

	printf "${YELLOW}new repo-name${NC}\n";
	printf "• Creates a new installation called 'repo-name'\n";
	printf "• 'repo-name' should match a repository that you've already created.\n\n";

	printf "${YELLOW}push repo-name${NC}\n";
	printf "• Builds and push's up the 'repo-name' repository and the database.\n";
	printf "• 'repo-name' should be an existing repository/site.\n\n";

	printf "${YELLOW}pull repo-name${NC}\n";
	printf "• Pulls down the 'repo-name' repository and sets up a local environment.\n";
	printf "• 'repo-name' should be an existing repository/site.\n\n";

	printf "${YELLOW}template template-name${NC}\n";
	printf "• Creates a page/template file and a Sass file.\n";
	printf "• Replace 'template-name' with the name of the template you'd like to create.\n";
	printf "• You must be in the ${CYAN}THEME ROOT${NC} to use this command.\n\n";

	printf "${YELLOW}archive post-type${NC}\n";
	printf "• Creates the archive/single/template files and a Sass file.\n";
	printf "• Replace 'post-type' with the name of the archive you'd like to create.\n";
	printf "• You must be in the ${CYAN}THEME ROOT${NC} to use this command.\n\n";

	printf "${YELLOW}root project-name${NC}\n";
	printf "• Navigates to the WordPress root directory for the project you specified.\n";
	printf "• Project-name must be an existing directory within the users 'projects directory'\n\n";

	printf "${YELLOW}theme project-name${NC}\n";
	printf "• Navigates to the Liquid theme directory for the project you specified.\n";
	printf "• Project-name must be an existing directory within the users 'projects directory'\n";

	printf "\n";
}

# ============================================= #
# ==== Color variables for output messages ==== #
# ============================================= #

RED='\033[0;31m'
PURPLE='\033[0;35m'
BLUE='\033[1;34m'
WHITE='\033[1;37m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NC='\033[0m'


# ============================ #
# ==== WP Salts Generator ==== #
# ============================ #

liquidCLI:wpsalts() {
	salt="'"`head -c 64 /dev/random | base64`"'";
	echo $salt;
}

# ===================================== #
# ==== Liquid Theme New Site Build ==== #
# ====  Run: liquid new site-name  ==== #
# ===================================== #

function liquidCLI:new() {
	## Check to see if the repo name was given
	if [[ "$1" ]]
	then
		site=$1;
	else
		read -r -p "What's the name of the site you'd like to build? " response
		if [[ $response ]];
		then
			site=$response;
		fi
	fi

	if [[ "$site" ]]
	then

		## Check if the site already exists in your projects directory
		if [ ! -d "${site}/" ];
		then

			## All checks were successful, proceed with installation
			liquidCLI:logo;
			printf "\n";

			## Install Bedrock from the Roots github repository
			printf "${CYAN}Working:${NC} Installing Bedrock... \n\n";
			git clone https://github.com/roots/bedrock.git $site --quiet;
			cd $site;
			rm -rf .git;
			printf "${GREEN}Success:${NC} Installed Bedrock application framework. \n\n";

			## Install Composer Dependancies;
			printf "${CYAN}Working:${NC} Installing Composer dependencies... \n\n";
			composer install --quiet;
			printf "${GREEN}Success:${NC} Installed Composer dependencies. \n\n";

			## Create a .env file
			echo "DB_NAME=wordpress
DB_USER=root
DB_PASSWORD=root
DB_HOST=localhost

WP_ENV=development
WP_HOME=http://$site.dev
WP_SITEURL=http://$site.dev/wp

AUTH_KEY="`liquidCLI:wpsalts`"
SECURE_AUTH_KEY="`liquidCLI:wpsalts`"
LOGGED_IN_KEY="`liquidCLI:wpsalts`"
NONCE_KEY="`liquidCLI:wpsalts`"
AUTH_SALT="`liquidCLI:wpsalts`"
SECURE_AUTH_SALT="`liquidCLI:wpsalts`"
LOGGED_IN_SALT="`liquidCLI:wpsalts`"
NONCE_SALT="`liquidCLI:wpsalts` > .env;

			## Remove the /public/app/ directory and git clone a new one
			printf "${CYAN}Working:${NC} Downloading Liquid theme... \n\n";
			cd web/app/themes;
			git clone git@github.com:getfluid/liquid.git liquid --quiet;
			printf "${GREEN}Success:${NC} Installed the Liquid theme files. \n\n";

			## NPM & Bower stuff
			printf "${CYAN}Working:${NC} Installing Node and Bower dependencies... \n\n";
			cd liquid;
			rm -rf .git;
			npm install;
			bower install;
			gulp build --silent;
			printf "\n";
			printf "${GREEN}Success:${NC} Node and Bower dependancies installed. \n\n";

			## Gulp Watch
			printf "${YELLOW}Completed:${NC} Compiling assets... \n\n";
			gulp;

		else
			cd;
			printf "${RED}Hold up:${NC} It looks like this project already exists on your computer. Delete it before attempting again.\n";
		fi

	else
		cd;
		printf "${RED}Hold up:${NC} You need to specify the site you'd like to build. Try running 'liquid new site-name'.\n";
	fi
	site='';
}

# ============================================= #
# ====  Liquid Theme New Template Function ==== #
# ====  Run: liquid template template-name ==== #
# ============================================= #

function liquidCLI:template() {
	if [ -d "templates/" ];
	then
		if [[ "$1" ]]
		then
			template=$1;
		else
			read -r -p "What would you like to name this template? " response
			if [[ $response ]];
			then
				template=$response;
			fi
		fi

		if [[ "$template" ]]
		then
			if [ -f "template-$template.php" ]
			then
				printf "${RED}Hold up:${NC} Template page already exists.\n";
			else
				if [ -f "templates/page-$template.php" ]
				then
					printf "${RED}Hold up:${NC} Template part already exists.\n";
				else
					if [ -f "assets/styles/layouts/_$template.scss" ];
					then
						printf "${RED}Hold up:${NC} SCSS file already exists.\n";
					else
  					input=$template;
						str=${input//-/' '};
						tmp=$( echo "${str}" | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1');

						## Create template page in root directory
						echo "@layout( 'base' )

{{-- Template Name: $tmp

@section('content')

	@wpposts
		@include('templates.page-$template')
	@wpempty
	@wpend

@endsection" > template-$template.php;

						## Create page template in /template directory
						echo "<h1>Page Template for $tmp</h1>" > templates/page-$template.blade.php;

						## Create Sass file in /assets/styles/layouts directory
						touch assets/styles/layouts/_$template.scss;
						echo "@import 'layouts/$template';" >> assets/styles/main.scss

						printf "${GREEN}Success:${NC} New template '$tmp' created.\n";
					fi
				fi
			fi
		else
			printf "${RED}Hold up:${NC} You need to enter the name of the template.\n";
		fi
	else
		printf "${RED}Hold up:${NC} Make sure you're in the root of the theme folder.\n";
	fi
	template='';
}

# =========================================== #
# ==== Liquid Theme New Archive Function ==== #
# ====   Run: liquid archive post-type   ==== #
# =========================================== #


function liquidCLI:archive() {
	if [ -d "assets/" ];
	then
		if [[ "$1" ]]
		then
			archive=$1;
		else
			read -r -p "What would you like to name this archive? " response
			if [[ $response ]];
			then
				archive=$response;
			fi
		fi

		if [[ "$archive" ]]
		then
			if [ -f "archive-$archive.php" ];
			then
				printf "${RED}Hold up:${NC} Archive page already exists.\n";
			else
				if [ -f "single-$archive.php" ];
				then
					printf "${RED}Hold up:${NC} Single page already exists.\n";
				else
					if [ -f "assets/styles/layouts/_$archive.scss" ];
					then
						printf "${RED}Hold up:${NC} SCSS file already exists.\n";
					else
						input=$archive;
						str=${input//-/' '};
						wpn=${input//-/'_'};
						tmp=$( echo "${str}" | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1');

						## Create archive page in root directory
						echo "@layout('base')

@section('content')

	@include('templates.content-$archive')

@endsection" > archive-$wpn.php;

						## Create single page in root directory
						echo "@layout('base')

@section('content')

@wpposts
	@include('templates.single-$archive')
@wpempty
@wpend

@endsection" > single-$wpn.php;

						## Create content template in /template directory
						echo "@wpposts
  <h1>Archive page for $tmp</h1>
@wpempty
	<div data-alert class=\"alert-box warning radius\">
  	{{ _e('Sorry, no results were found.', 'sage') }}
	</div>
	{{ get_search_form() }}
@wpend

@if (\$wp_query->max_num_pages > 1)
	{{ LiquidPagination() }}
@endif" > templates/content-$archive.blade.php;

						## Create single template in /template directory
						echo "<h1>Single page for $tmp</h1>" > templates/single-$archive.blade.php;

						## Create Sass file in /assets/styles/layouts directory
						touch assets/styles/layouts/_$archive.scss;
						echo "@import 'layouts/$archive';" >> assets/styles/main.scss

						printf "${GREEN}Success:${NC} New archive and single page '$tmp' created.\n";
					fi
				fi
			fi
		else
			printf "${RED}Hold up:${NC} You need to enter the plural name of the post type.\n";
		fi
	else
		printf "${RED}Hold up:${NC} Make sure you're in the root of the theme folder.\n";
	fi
	archive='';
}

# ==================================================== #
# ==== Main function that calls all other methods ==== #
# ==================================================== #

liquid() {
	if [[ "$1" = "new" ]]
	then
		liquidCLI:new $2 $3

	elif [[ "$1" = "template" ]]
	then
		liquidCLI:template $2

	elif [[ "$1" = "archive" ]]
	then
		liquidCLI:archive $2

	else
		liquidCLI:info
	fi
}
