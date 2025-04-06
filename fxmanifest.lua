fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'gkun'
description 'Anchor Script'
version '1.0.0'

shared_script {
    'config.lua',
    '@ox_lib/init.lua',
}
client_script {
    'locale/locale.lua',
    'client/client.lua',
}
server_script {
    'server/server.lua'
}
