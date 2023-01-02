#!/bin/bash

# preparing the code
cd /jellyfin
cd jellyfin-web

SKIP_PREPARE=1 npm ci --no-audit
npm run build:production

#Following 4 commands may be required (do not remember exactly if required):
npm install date-fns
npm install --save-dev webpack
npm install -g webpack
npm install -g webpack-cli

# Next command takes long time, and does not update screen during opration, do not interrupt
npx browserslist@latest --update-db

# Following takes very long time:
npm ci --no-audit --loglevel verbose
cd ../jellyfin-tizen

JELLYFIN_WEB_DIR=../jellyfin-web/dist npm ci --no-audit

chown -R tizen:tizen /jellyfin/jellyfin-tizen
chown -R tizen:tizen /jellyfin/jellyfin-web