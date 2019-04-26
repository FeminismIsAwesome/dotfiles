#! /bin/bash

if [[ ! -e "$HOME/.pairs" ]]; then
  echo 'linking ~/.pairs to use the version from the dotfiles repo'
  ln -s "$DIR/rc_files/pairs" ~/.pairs
fi
if [[ ! -e "$HOME/.git-authors" ]]; then
  ln -s "$DIR/rc_files/pairs" ~/.git-authors
fi

function setup_git_duet() {
  export GIT_DUET_GLOBAL=1
  # duet settings only good for 3 hours
  export GIT_DUET_SECONDS_AGO_STALE=`expr 60 \* 60 \* 8`
  alias solo='git solo $(command git config --global --get duet.env.git-author-initials 2>/dev/null)'
  alias local_user='duet_user'
  rotate_author
}

function enable_git_duet() {
  if [ -e "$HOME/.git-duet-enabled" ]; then
    echo "git duet is already enabled"
  else
    echo 'installing git duet'
    brew tap git-duet/tap
    brew install git-duet
    # this script had a bug that was fixed in an unreleased version, included so things will work better
    echo "Please enter your laptop password to save a corrected file into /usr/local/bin"
    cp fixed_files/git-duet-pre-commit /usr/local/Cellar/git-duet/0.6.0/bin/git-duet-pre-commit
    chmod +x /usr/local/Cellar/git-duet/0.6.0/bin/git-duet-pre-commit
    # install git wrapper for rubymine with duet
    if [[ ! -e "/usr/local/bin/rubymine-git-wrapper" ]]; then
      curl -Ls -o /usr/local/bin/rubymine-git-wrapper https://raw.github.com/git-duet/git-duet/master/scripts/rubymine-git-wrapper
      chmod +x /usr/local/bin/rubymine-git-wrapper
    fi
    # this kind of override doesnt seem to work
    #ln -s /usr/local/bin/git-duet-commit /usr/local/bin/git-commit
    setup_git_duet
  fi
  echo "Please update your RubyMine setting in Preferences => Version Control => Git"
  echo "to set Path to Git executable to the full path of /usr/local/bin/rubymine-git-wrapper"

  touch "$HOME/.git-duet-enabled"
}

function disable_git_duet() {
  if [ -e "$HOME/.git-duet-enabled" ]; then
    #rm /usr/local/bin/git-commit
    rm "$HOME/.git-duet-enabled"
    alias_git_commit
  else
    echo "git duet is not enabled"
  fi

}

function signoff() {
  unset GIT_DUET_CO_AUTHORED_BY
  unset GIT_DUET_ROTATE_AUTHOR
  export GIT_DUET_SET_GIT_USER_CONFIG=1
  alias_git_duet_commit
  if [ -e ".git/hooks/prepare-commit-msg" ]; then
    rm .git/hooks/prepare-commit-msg
  fi
}

function coauthor() {
  unset GIT_DUET_SET_GIT_USER_CONFIG  # Implicitly enabled in co-author mode
  unset GIT_DUET_ROTATE_AUTHOR  # Unnecessary in co-author mode
  export GIT_DUET_CO_AUTHORED_BY=1

  # Co-author mode doesn't require `git duet-commit` or other duet-specific git commands, so
  # let's restore the original, non-duet aliases.
  alias_git_commit

  if [[ ! -f "$HOME/.git-template/hooks/prepare-commit-message" ]]; then
    git duet
  fi
  if [ -d ".git" ]; then
    git init
  fi
}

function rotate_author() {
  unset GIT_DUET_CO_AUTHORED_BY
  export GIT_DUET_ROTATE_AUTHOR=1
  export GIT_DUET_SET_GIT_USER_CONFIG=1
  alias_git_duet_commit
  if [ -e ".git/hooks/prepare-commit-msg" ]; then
    rm .git/hooks/prepare-commit-msg
  fi
}

alias solo="git config --local --remove-section user"

function alias_git_duet_commit() {
  alias gc="git duet-commit -v"
  alias gcm="git duet-commit -m"
  alias gcam="git duet-commit -v --amend"
  alias gca="git add -A . && git duet-commit -v"
  alias gcaam="git add -A . && git duet-commit -v --amend"
  alias gacn="git add -A . && git duet-commit --amend --no-edit"
  alias gfa="git duet-commit --amend --reset-author --no-edit"
  alias gcw="git add -A . && git duet-commit -m '[#0] WIP'"
}


function local_user() {
  local pair=""
  for person in $(command git config --local --get user.initials 2>/dev/null); do
    pair+=$person
  done

  if [ -z "$pair" ]; then
    :
  else
    echo -n " "$pair" "
  fi
}

function duet_user() {
  local pair=$(command git config --global --get duet.env.git-author-initials 2>/dev/null)
  pair+=$(command git config --global --get duet.env.git-committer-initials 2>/dev/null)
  local stale_cutoff=$(($(command git config --global --get duet.env.mtime 2>/dev/null) + $GIT_DUET_SECONDS_AGO_STALE))

  if [ `date +%s` -gt "$stale_cutoff" ]; then
    pair+=" (STALE)"
  fi

  if [ -z "$pair" ]; then
    :
  else
    echo -n " "$pair" "
  fi
}




if [ -e "$HOME/.git-duet-enabled" ]; then
  setup_git_duet
fi
