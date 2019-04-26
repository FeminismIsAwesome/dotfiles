alias d="docker"
alias dc="docker-compose"
alias dcrun="docker-compose run --rm"
alias drma='docker rm $(docker ps -aq)'
alias drmi='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
alias dclean="docker container prune && docker image prune"
