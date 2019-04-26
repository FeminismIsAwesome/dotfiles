function source_from_files() {
  for dotfile in $*; do
    source $dotfile
  done
}

function source_from_files_zsh() {
  for dotfile in $*; do
    ext="${dotfile##*.}"
    # Only check the extension if we are using zsh
    if [[ "$ext" == "sh" ]]; then
      filename="${dotfile%.*}"

      # Only source the sh file if a zsh file does not exist with the same name
      if [[ ! -f "${filename}.zsh" ]]; then
        source $dotfile
      fi
    else
      source $dotfile
    fi
  done
}

function source_all_dotfiles() {
  local DIR="$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )"

  export PATH=$PATH:$DIR/bin

  if [[ -n ${ZSH_VERSION-} ]]; then
    source_from_files_zsh `ls $DIR/dotfiles.d/*.{sh,zsh}`
  else
    source_from_files `ls $DIR/dotfiles.d/*.sh`
  fi
  source_from_files `ls $DIR/dotfiles.d/*/*.sh`
}

source_all_dotfiles

if [[ ${DFS_AUTO_UPDATE:-0} == 1 ]]; then
  DFS_DIR="$( dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )"
  source $DFS_DIR/script/update_check.sh
fi