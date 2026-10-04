fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'vital-hud'
author 'vital'
description 'Vital HUD'
version '1.0.0'

ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/**/*',
}

client_script 'client/main.lua'
server_script 'server/main.lua'
