@ECHO on

set /p DeployLocation=<deploy_location.txt
echo Deploying to %DeployLocation%
xcopy worksessions %DeployLocation% /y /d

set /p GitLocation=<git_location.txt
echo Committing to %GitLocation%
cd %GitLocation%
git add --all
git commit -m "Adding kinect work session"