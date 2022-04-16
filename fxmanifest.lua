fx_version 'cerulean'
game 'gta5'

description 'tnj-edior, made with ♥ from aj'
version '1.0.0'

client_scripts {
    '@menuv/menuv.lua',
    'config.lua',
    'client.lua'
}
server_script 'server.lua'

dependency 'menuv' -- Makes sure menuv starts before this script

lua54 'yes'