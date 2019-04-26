#@IgnoreInspection BashAddShebang

if [ ! -z $TERM_PROGRAM ]; then
  red='\033[0;31m'
  green='\033[0;32m'
  yellow='\033[0;33m'
  NC='\033[0m'
else
  OUTPUT_OPTIONS="--no-color --format simple"
  red=''
  green=''
  yellow=''
  NC=''
fi
