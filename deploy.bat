@ECHO off
set /p DeployLocation=<deploy_location.txt
echo Deploying to %DeployLocation%

xcopy worksessions %DeployLocation% /y /d