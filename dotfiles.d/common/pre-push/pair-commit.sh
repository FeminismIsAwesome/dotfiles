#@IgnoreInspection BashAddShebang

function commit_has_co_author() { git show -s --format=%B "${sha}" | grep -q '^Co-authored-by: '; }
function is_duet_commit() { [[ ${author_email} != ${committer_email} ]] || commit_has_co_author; }
function is_pair_commit() { [[ -n `echo ${author_email} | awk '/^pair\+[^+]+\+[^@]+@companyemail.com$/'` ]]; }

while read local_ref local_sha remote_ref remote_sha; do
  [[ ${remote_ref} == 'refs/heads/master' ]] || continue

  git log --pretty=format:"%ae %ce %h" "$remote_sha..$local_sha" | while read line || [[ -n ${line} ]]; do
    read author_email committer_email sha <<< ${line}

    is_duet_commit || is_pair_commit || {
      printf ${yellow}${sha}
      printf "${red} Solo commits to master are not allowed. Use git-duet, git-pair, or create a pull request.${NC}\n"
      exit 1
    }
  done
done
