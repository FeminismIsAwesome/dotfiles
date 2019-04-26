# Dotfiles

Targets Bash on Mac OS for git workflows

- Custom prompt showing login, current path, git branch, and git info
- Git command aliases

## Installation

Clone the dotfiles repo

Source dotfiles.sh in your .bash_profile / .zshrc, e.g.:

	source "$HOME/workspace/dotfiles/dotfiles.sh"

This will pull in all files in the dotfiles.sh directory.

Additionally, copy each file in rc_files to an equivalent .<file_name> in your home folder.

Install jq on your computer
    
    brew install jq

## Auto update

You can add an auto update feature to Dotfiles to check every 7 days if there are updates and then update your repository

You can customize the number of days changing the `UPDATE_DFS_DAYS` variable. More options in [here](script/update_check.sh)

To enable the feature, add this in your .bash_profile / .zshrc before sourcing `dotfiles.sh`:

    export DFS_AUTO_UPDATE=1
