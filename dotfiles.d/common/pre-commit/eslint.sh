#@IgnoreInspection BashAddShebang

if [ "$ESLINT" = false ]
then
  echo "Skipping ESLint"
else
  echo "Running ESLint on changed files, acquaintance"
  npm run lint-staged
  if [ $? -ne 0 ]; then
    printf "${red}[JS Style][Error]: Fix the issues for JS and commit again"
    exit 1
  fi
fi
