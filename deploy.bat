@ECHO off

:deploy
set /p DeployLocation=<deploy_location.txt
echo Deploying to %DeployLocation%
xcopy worksessions %DeployLocation% /y /d

if not "%1" == "commit" goto nocommit

:commit
set /p GitLocation=<git_location.txt
echo Committing to %GitLocation%
cd %GitLocation%
git --git-dir=%GitLocation%/.git/ --work-tree=%GitLocation% add --all
git --git-dir=%GitLocation%/.git/ --work-tree=%GitLocation% commit -m "Auto-Adding kinect work sessions"

:nocommit
echo not committing (call `deploy commit` if you want that)
:end
echo done.