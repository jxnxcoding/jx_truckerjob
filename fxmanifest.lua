---
fx_version "cerulean"
game "gta5"
---
author "jxScripts"
description "Simple FiveM Trucker Job for your server!"
version "1.0.0"
---
client_scripts {
    "@es_extended/locale.lua",
    "locales/en.lua",
    "locales/de.lua",
    "client/main.lua",
    "config.lua",
}
---
server_scripts {
    "@es_extended/locale.lua",
    "server/main.lua",
    "config.lua",
}
---
shared_script "@es_extended/imports.lua"
---
files {
    "ui/index.html",
    "ui/style.css",
    "ui/script.js",
}
---