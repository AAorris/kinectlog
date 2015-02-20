@ECHO off

set /p DeployLocation=<deploy_location.txt
echo Deploying to %DeployLocation%
xcopy worksessions %DeployLocation% /y /d

set /p GitLocation=<git_location.txt
echo Committing to %GitLocation%
cd %GitLocation%
git add .
git commit -m "Adding kinect work session"