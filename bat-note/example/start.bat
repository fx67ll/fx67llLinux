@echo off
call pm2 stop all
call pm2 delete all
cd bin
set startDir=%cd%
call pm2 start www
start http://localhost:3000