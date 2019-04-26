#@IgnoreInspection BashAddShebang

if [ "$RUBOCOP" = false ]
then
  echo "Skipping RuboCop"
else
  echo "Running RuboCop on changed files, friend"

  # Get only the staged files
  FILES="$(git diff --cached --name-only --diff-filter=AMC *.rb *.rake)"

  if [ -n "$FILES" ]
  then
    if [[ -n `which osascript` ]]; then
      osascript -e 'display notification "Kicking off pre-commit style check" with title "Rubocop"'
    fi
    printf "${green}[Ruby Style][Info]: Checking Ruby Style${NC}\n"

    # Check if rubocop is installed for the current project
    unset GIT_DIR
    rvm_silence_path_mismatch_check_flag=1
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
    version=`cat .ruby-version`
    gemset=`cat .ruby-gemset`
    rvm use ${version}@${gemset} --create >/dev/null 2>&1

    printf "${green}[Ruby Style][Info]: ${FILES}${NC}\n"

    if [ ! -f '.rubocop.yml' ]; then
      printf "${yellow}[Ruby Style][Warning]: No .rubocop.yml config file.${NC}\n"
    fi

    # Run rubocop on the changed files
    bundle exec rubocop -a -D ${OUTPUT_OPTIONS} ${FILES}

    if [ $? -ne 0 ]; then
            printf "${red}[Ruby Style][Error]: Fix the issues and commit again, or try rubocop --auto-correct${NC}\n"
      exit 1
    fi

    git diff --exit-code ${FILES}

     if [ $? -ne 0 ]; then
                printf "${red}[Ruby Autocorrected Shit][Error]: You'll want to add autocorrected changes${NC}\n"
          exit 1
        fi
  else
    printf "${green}[Ruby Style][Info]: No Ruby files Changed${NC}\n"
  fi
fi
