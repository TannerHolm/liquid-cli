#!/usr/bin/env node

cd ..;
git clone https://github.com/WordPress/WordPress.git liquid --quiet;
cd liquid;
cd wp-content;
cd themes;
git clone https://github.com/getfluid/liquid.git --quiet;
cd liquid;
npm install -g gulp bower;
bower install;
npm install;
gulp build;
