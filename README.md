# platypodes
CS 4154 - fall 2015 - team platypodes

## GIT POLICIES
This repo will mostly follow the git procedures listed here:
http://nvie.com/posts/a-successful-git-branching-model/

Most importantly:
- NEVER COMMIT DIRECTLY TO DEVELOP OR MASTER ONCE THE REPO IS UP. EVER.  
- all new feature work should be done on feature branches, branched off of develop
- Never directly merge your new feature yourself without 
- Never push a feature branch to github

# How To...
start working on a new feature:
- git checkout develop
- git pull origin develop --rebase
- git checkout -b \<NameOfFeature\>

update your feature branch with to the current develop
- git checkout develop
- git pull origin develop --rebase
- git merge \<NameOfFeature\> --no-ff

submit your feature branch for pull request
- use pull request tool on github
- ... commandline option coming soon
