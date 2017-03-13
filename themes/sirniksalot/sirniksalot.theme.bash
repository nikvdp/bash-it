

parse_git_dirty () {
    [[ $(git status 2> /dev/null | tail -n1 | cut -c 1-17) != "nothing to commit" ]] && echo "*"
}
parse_git_branch () {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

color_parse_git_branch() {
    local branch="$(parse_git_branch)"
    if [[ -n "$branch" ]]; then
        # \001 and \002 are equivalent to \[ and \], and are used to help bash count non-printable chr
        # length properly
        # (see http://stackoverflow.com/questions/19092488/custom-bash-prompt-is-overwriting-itself)
        echo "${white}($PURPLE${branch}$white) "
    fi
}

conditional_py_prompt() {
    local py_color="\001$cyan\002"
    if [[ -n "$(condaenv_prompt)$(virtualenv_prompt)" ]]; then
        echo -e "${py_color}($(condaenv_prompt)$(virtualenv_prompt):${py_color}$(py_interp_prompt)) "
    fi
}

function prompt_command() {
    local last_cmd_exit=$?
    local last_cmd_success_color="${green}"
    local last_cmd_fail_color="${red}"
    local full_reset="$(tput sgr0)"

    local cmd_status_color="$last_cmd_success_color"

    local police_emoji=$'\xf0\x9f\x9a\x94'" "
    local bell_emoji=$'\xf0\x9f\x9a\xa8'" "

    local fail_status_alert_msg="${bell_emoji} ${police_emoji} ${bell_emoji} "

    local line1_arr=()

    if [[ "$last_cmd_exit" -ne "0" ]]; then
        cmd_status_color="$last_cmd_fail_color"
    fi

    line1_arr+=(
        ${cmd_status_color}
        '\w'  # current path
        ${white}
        ' on '
        ${purple}
        ' \h '  # hostname
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
            ${py_color}
            '('
            ${python}  
            ':'
            ${cyan}
            $(py_interp_prompt)  # python interpreter (from bash-it)
            ') '
        )
        fi

    local line2_arr=(
        $cmd_status_color
        '['
        $prompt_thingy
        ' ] '
    )
    

    line1_arr+=($full_reset)
    line2_arr+=($full_reset)

    local line1=
    for i in "${line1_arr[@]}"; do
        line1="${line1}\\[$i\\]"
    done

    local line2=
    for i in "${line2_arr[@]}"; do
        line2="${line2}\\[$i\\]"
    done

    PS1="\n$line1\n\r     \r$line2"
}

function emoji-to-bash-escape-seq () {
    local emoji="$1"
    echo -n "$emoji" | hexdump | head -1 | sed -e 's/^0* /\\x/g' -e 's/[ ]*$//g' -e 's/ /\\x/g' -e "s/^/\\$'/" -e "s/\$/'/" 
}

safe_append_prompt_command prompt_command
