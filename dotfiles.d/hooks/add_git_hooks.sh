#!/bin/sh

DOTFILES_HOME=$HOME/workspace/dotfiles/dotfiles.d
WORKSPACE_HOME=$HOME/workspace/myNewWorkspaceName
WORKSPACE_GIT_HOOKS=$WORKSPACE_HOME/.git/hooks

if [ -d ${WORKSPACE_HOME} ]; then
  cp $DOTFILES_HOME/common/commit-msg $WORKSPACE_GIT_HOOKS
  chmod +x $WORKSPACE_GIT_HOOKS/commit-msg

  echo \#\!/bin/bash > $WORKSPACE_GIT_HOOKS/pre-commit
  cat $DOTFILES_HOME/common/variables.sh >> $WORKSPACE_GIT_HOOKS/pre-commit
  cat $DOTFILES_HOME/common/pre-commit/rubocop.sh >> $WORKSPACE_GIT_HOOKS/pre-commit
  cat $DOTFILES_HOME/common/pre-commit/eslint.sh >> $WORKSPACE_GIT_HOOKS/pre-commit
  cat $DOTFILES_HOME/common/pre-commit/git-duet.sh >> $WORKSPACE_GIT_HOOKS/pre-commit
  chmod +x $WORKSPACE_GIT_HOOKS/pre-commit

  echo \#\!/bin/bash > $WORKSPACE_GIT_HOOKS/pre-push
  cat $DOTFILES_HOME/common/variables.sh >> $WORKSPACE_GIT_HOOKS/pre-push
  cat $DOTFILES_HOME/common/pre-push/pair-commits.sh >> $WORKSPACE_GIT_HOOKS/pre-push
  chmod +x $WORKSPACE_GIT_HOOKS/pre-push
fi
