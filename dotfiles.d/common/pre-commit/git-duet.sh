#@IgnoreInspection BashAddShebang

if [ -z "$DISABLE_DUET" ]; then
  if [ -e "$HOME/.git-duet-enabled" ]; then
    set -e
    git duet-pre-commit
    set +e
  fi
fi
