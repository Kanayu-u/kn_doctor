fx_version 'cerulean'
game 'gta5'

author 'Kanayu_u'
description 'Optimized Doctor NPC for Revive & Heal (Standalone/ox-based)'
version '1.2.0'


dependency 'ox_lib'

shared_scripts {
    'config.lua',
    'locales/en.lua',
    'locales/ja.lua',
    'locales/loader.lua',
}

client_scripts {
    '@ox_lib/init.lua',
    'client/notify.lua',
    'client/utils.lua',
    'client/main.lua'
}

server_scripts {
    '@ox_lib/init.lua',
    'server/bridge.lua',
    'server/main.lua'
}

lua54 'yes'

ui_page 'html/notify.html'

files {
    'html/notify.html',
    'html/notify.css',
    'html/notify.js',
}
