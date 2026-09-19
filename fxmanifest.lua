fx_version 'cerulean'
game 'gta5'

author 'Kanayu_u'
description 'Optimized Doctor NPC for Revive & Heal (Standalone/ox-based)'
version '1.1.3'


dependency 'ox_lib'

shared_scripts {
    'config.lua',
    'locales/en.lua',
    'locales/ja.lua',
    'locales/loader.lua',
}

client_scripts {
    '@ox_lib/init.lua',
    'client/utils.lua',
    'client/main.lua'
}

server_scripts {
    '@ox_lib/init.lua',
    'server/bridge.lua',
    'server/main.lua'
}

lua54 'yes'
