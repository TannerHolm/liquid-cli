#!/usr/bin/env bash
# ============================================ #
# ====          Liquid CLI v1.2.0         ==== #
# ====  By: Zack Warren, Spencer Merritt  ==== #
# ============================================ #

# ===================== #
# ==== Liquid Logo ==== #
# ===================== #

	printf "${YELLOW}
   __   _           _    __
  / /  (_)__  __ __(_)__/ /
 / /__/ / _ \/ // / / _  /
/____/_/\_  /\_,_/_/\_,_/
         /_/
${NC}
 WordPress Theme Installer
===========================\n";
cd ..;
git clone https://github.com/WordPress/WordPress.git liquid --quiet;
cd liquid;
cd wp-content;
cd themes;
rm -rf .;
git clone https://github.com/getfluid/liquid.git --quiet;
cd liquid;
sudo npm install -g gulp bower;
bower install;
npm install;
gulp build;
