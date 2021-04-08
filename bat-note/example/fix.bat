@echo off
rd /s/q node_modules
del package-lock.json
call npm install
call npm install pm2 -g
call pm2 update
call pm2 stop all
call pm2 delete all
cd bin
set startDir=%cd%
call pm2 start www
call pm2 log 0