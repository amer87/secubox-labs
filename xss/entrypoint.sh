#!/bin/sh
sed -i "s|__CTF_FLAG__|${CTF_FLAG}|g" /usr/share/nginx/html/index.html
exec nginx -g "daemon off;"