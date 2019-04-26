SOURCE=$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )

git config --global alias.st status
git config --global alias.co checkout
git config --global alias.cm 'commit -m'
git config --global alias.tree "log --graph --all --decorate --oneline --abbrev-commit"

alias gst='git status'
alias gcl="git clone"

alias ga="git add"
alias gall="git add -A"
alias gap="git add --patch"

alias gs="git status -s && git stash list"
alias gsf="git show -s --format=full"
alias gsh="git show"
alias gsn="git show --name-only"
alias gl="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"
alias glf='git log --format=full'
alias glg="git tree"
alias glh="gl | head"

function gd() {
  git diff
  local untracked="$(git ls-files --others --exclude-standard)"
  if [ ! -z $untracked ]; then
    echo -e "\n${WHITE}Untracked files:${NC}"
    echo $untracked
  fi
}
alias gds="git diff --staged"
alias gda='git diff HEAD'
alias gdn="git diff --name-only"

alias gdc="git duet-commit"
alias gdrv="git duet-revert"
alias gdmg="git duet-merge"
alias gdrb="git rebase --exec 'git duet-commit --amend'"

alias gri="git rebase -i"

alias stories="$SOURCE/getmestories"

function alias_git_commit() {
  alias gc="git commit -v"
  alias gcm="git commit -m"
  alias gcam="git commit -v --amend"
  alias gca="git add -A . && git commit -v"
  alias gcaam="git add -A . && git commit -v --amend"
  alias gacn="git add -A . && git commit --amend --no-edit"
  alias gfa="git commit --amend --reset-author --no-edit"
  alias gcw="git add -A . && git commit -m '[#0] WIP'"
}
alias_git_commit

alias gco="git checkout"
alias gcop="git checkout -p"

# nuke all uncommitted changes
alias gnuke="git add -A && git checkout -f"
# make a stash of the current uncommitted changes
alias gsnap="git stash -u && git stash apply"

alias gm="git checkout master"
alias grm='git co master && gv && git co - && git rebase master'

alias gcp="git cherry-pick"

alias g!="git add -A . && git checkout -f"
function gcun() {
  local commit_message="$(git log -n 1 HEAD 2>/dev/null)"
  pbcopy commit_message
  git reset --soft HEAD^ && git reset HEAD .
}

alias gsl="git stash list"
function g{ () {
  echo -n "Name this stash (optional): "
  read name
  if [[ -n $name ]]
    then git stash save -u "$name"
    else git stash -u
  fi
}
alias g}='git stash pop'

alias g^="git push origin HEAD"
alias gv="git pull --rebase"
alias gv^="git pull --rebase && git push origin HEAD"
alias gvm="gv && migrate"

alias gb="git branch"
alias gbl="git for-each-ref --sort=-committerdate refs/heads/"
alias gbr="git branch -r"
function grb() {
  if [ -n "$1" ]; then
    git push origin HEAD:refs/heads/$1
    git fetch origin &&
    git checkout -b $1 --track origin/$1
  else
    git branch --set-upstream `current_git_branch` origin/`current_git_branch`
  fi
}

function prune_branch() {
  local branch_name=$1

  echo -n "Are you sure you want to delete $branch_name? (y/n) "
  read confirmation
  if [ $confirmation != "y" ]; then
    return 1
  fi

  if [ -n "$branch_name" ]; then
    if [ -n "`git branch --list \"$branch_name\"`" ]; then
      echo "Found local branch, deleting..."
      git branch -D "$branch_name"
    else
      echo "Found no local branch with that name"
    fi

    if [ -n "`git branch -r --list \"origin/$branch_name\"`" ]; then
      echo "Found remote branch, deleting..."
      git push origin ":$branch_name"
    else
      echo "Found no remote branch with that name"
    fi
  else
    echo "You need to provide a branch name to prune."
  fi
}
alias pbr="prune_branch"

function current_git_branch() {
  local git_dir="$(git rev-parse --git-dir 2>/dev/null)"
  local git_branch
  if [ -d "$git_dir" ]; then
    git_branch=`git symbolic-ref HEAD 2>/dev/null || git describe --exact-match HEAD 2>/dev/null | cut -c1-7 "$git_dir/HEAD"`
    git_branch=${git_branch#refs/heads/}
    echo -n $git_branch
  fi
}

alias mcd="git log `current_git_branch` ^master --no-merges"
alias cbn="echo `current_git_branch` | pbcopy"

function git_special() {
  wrap_unless_empty "`git_mode`" "`git_commits_ahead`" "`git_commits_behind`" "`git_dirty_state`"
}

function wrap_unless_empty() {
  if [ -n "$1" ] || [ -n "$2" ] || [ -n "$3" ] || [ -n "$4" ]; then
    echo -n "($1$2$3$4)"
  fi
}

function git_mode() { # [1]
  local git_dir="$(git rev-parse --git-dir 2>/dev/null)"
  local git_mode
  if [ -f "$git_dir/BISECT_LOG" ] ; then
    git_mode='BISECTING'
  elif [ -f "$git_dir/rebase-merge/interactive" ] ; then
    git_mode='REBASE-i'
  elif [ -f "$git_dir/rebase-apply/rebasing" ] ; then
    git_mode='REBASE'
  elif [ -f "$git_dir/MERGE_HEAD" ] ; then
    git_mode='MERGING'
  fi
  echo -n $git_mode
}

function git_commits_ahead() {
  git status -sb 2> /dev/null | head -n 1 | grep ahead | sed -e 's/.*ahead \([0-9]\{1,\}\).*/+\1/'
}

function git_commits_behind() {
  git status -sb 2> /dev/null | head -n 1 | grep behind | sed -e 's/.*behind \([0-9]\{1,\}\).*/-\1/'
}

function add_story_prehook() {
  echo $SOURCE
  cp ${SOURCE}/git-story /usr/local/bin/git-story
  chmod +x /usr/local/bin/git-story
  cp ${SOURCE}/prepare-commit-msg .git/hooks/prepare-commit-msg
  chmod +x .git/hooks/prepare-commit-msg
}

# Roughly from git_completion
function git_dirty_state() {
  if [ -n "`git status --porcelain 2>/dev/null`" ]; then
    echo -n "*"
  fi
}

# ignore simple aliases
export HISTIGNORE="gs:gc:gca:gd:gap:g^:gv:${HISTIGNORE}"

# [1] github.com/hashrocket/dotmatrix/commit/d888bfee55ca430ba109e011d8b0958e810f799a
