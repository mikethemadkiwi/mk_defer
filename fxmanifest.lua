--[[ FX Information ]]--
fx_version   'cerulean'
use_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'
--[[ Resource Information ]]--
name 'mk_defer'
author 'mikethemadkiwi'
description 'deferal script including basic queue + whitelist'
version '0.0.1'
--[[ Dependancies ]]--
dependencies {  
    '/onesync'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'mkdserver.lua'
}
