#/usr/bin/env bash

_dothis_completions() {
    COMPREPLY=($(compgen -W "start restart stop shutdown create-certs update-images delete-obsolete-images save-db cli" "${COMP_WORDS[1]}"))
}

if command -v complete &>/dev/null ; then
    complete -F _dothis_completions docker-lamp
fi