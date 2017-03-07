#!/usr/bin/env bash

_nik-conda-comp() {
    local cur prev envs
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    envs="$(get-conda-envs)"

    COMPREPLY=( $(compgen -W "${envs}" -- ${cur}) )
}
complete -F _nik-conda-comp act 
