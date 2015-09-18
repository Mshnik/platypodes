# platypodes
CS 4154 - fall 2015 - team platypodes

## GIT POLICIES
This repo will mostly follow the git procedures listed here:
http://nvie.com/posts/a-successful-git-branching-model/

Most importantly:
- NEVER COMMIT CODE DIRECTLY TO DEVELOP OR MASTER ONCE THE REPO IS UP.
- all new feature work should be done on feature branches, branched off of develop. NOT MASTER.
- Ideally, get all work checked by someone else before you merge it into develop.
- Never work on someone else's feature branch without their express request/consent.
- Delete your branch after merging it into develop so we don't get clogged.

# How To...
start working on a new feature:
- git checkout develop
- git pull --rebase origin develop
- git checkout -b \<NameOfFeature\>

update your feature branch with to the current develop, to pull in other people's changes
- git checkout develop
- git pull --rebase origin develop
- git checkout \<NameOfFeature\>
- git merge develop --no-ff

submit your feature branch to develop **after it has been checked**
- git checkout develop
- git pull --rebase origin develop
- git merge \<NameOfFeature\> --no-ff
- Note - in the merge message, write a list of the features the merge of this branch is adding.
