

parse_git_dirty () {
    [[ $(git status 2> /dev/null | tail -n1 | cut -c 1-17) != "nothing to commit" ]] && echo "*"
}
parse_git_branch () {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

function prompt_command() {
    local last_cmd_exit=$?
    local last_cmd_success_color="${green}"
    local last_cmd_fail_color="${red}"
    local full_reset="${reset_color}"

    local cmd_status_color="$last_cmd_success_color"

    local police_emoji="🚔 "
    local bell_emoji="🚨 "


    local line1_arr=()

    if [[ "$last_cmd_exit" -ne "0" ]]; then
        cmd_status_color="$last_cmd_fail_color"
        line1_arr+=(
            "${bell_emoji} "
            "${police_emoji} "
            "${bell_emoji} "
        )
    fi

    line1_arr+=(
        ${cmd_status_color}
        '\w'  # current path
        ${white}
        ' on'
        ${purple}
        ' \h'  # hostname
        ' '
    )

    # append git branch status if we're in a git branch
    local branch="$(parse_git_branch)"
    if [[ -n "$branch" ]]; then
        line1_arr+=(
            ${white}
            '('
            ${purple}
            ${branch}
            ${white}
            ')'
        )
    fi

    # append python virtualenv info if in a virtualenv
    local python=$(condaenv_prompt)$(virtualenv_prompt)  # only one of these will be filled at a time
    if [[ -n "$python" ]]; then
        line1_arr+=(
            ${cyan}
            '('
            ${python}  
            ':'
            ${cyan}
            $(py_interp_prompt)  # python interpreter (from bash-it)
            ') '
        )
        fi

    local line2_arr=(
        ${cmd_status_color}
        "[$prompt_thingy]"
        ' '
    )
    

    line1_arr+=($full_reset)
    line2_arr+=($full_reset)

    local line1=
    for i in "${line1_arr[@]}"; do
        line1="${line1}$i"
    done

    local line2=
    for i in "${line2_arr[@]}"; do
        line2="${line2}$i"
    done

    # PS1="\[\n\]$line1\[\n\]$line2"
    PS1="\n${line1}\n${line2}"
}

function emoji-to-bash-escape-seq () {
    local emoji="$1"
    echo -n "$emoji" | hexdump | head -1 | sed -e 's/^0* /\\x/g' -e 's/[ ]*$//g' -e 's/ /\\x/g' -e "s/^/\\$'/" -e "s/\$/'/" 
}

safe_append_prompt_command prompt_command
