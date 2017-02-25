# Sexy Bash Prompt, inspired by "Extravagant Zsh Prompt"
# Screenshot: http://cloud.gf3.ca/M5rG
# A big thanks to \amethyst on Freenode

if [[ $COLORTERM = gnome-* && $TERM = xterm ]]  && infocmp gnome-256color >/dev/null 2>&1; then export TERM=gnome-256color
elif [[ $TERM != dumb ]] && infocmp xterm-256color >/dev/null 2>&1; then export TERM=xterm-256color
fi

if tput setaf 1 &> /dev/null; then
    if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
      MAGENTA=$(tput setaf 9)
      ORANGE=$(tput setaf 172)
      GREEN=$(tput setaf 190)
      PURPLE=$(tput setaf 141)
      WHITE=$(tput setaf 0)
    else
      MAGENTA=$(tput setaf 5)
      ORANGE=$(tput setaf 4)
      GREEN=$(tput setaf 2)
      PURPLE=$(tput setaf 1)
      WHITE=$(tput setaf 7)
    fi
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    MAGENTA="\033[1;31m"
    ORANGE="\033[1;33m"
    GREEN="\033[1;32m"
    PURPLE="\033[1;35m"
    WHITE="\033[1;37m"
    BOLD=""
    RESET="\033[m"
fi

parse_git_dirty () {
    [[ $(git status 2> /dev/null | tail -n1 | cut -c 1-17) != "nothing to commit" ]] && echo "*"
}
parse_git_branch () {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
}

color_parse_git_branch() {
    local branch="$(parse_git_branch)"
    if [[ -n "$branch" ]]; then
        echo "${white}(\[$PURPLE\]${branch}$white) "
    fi
}

conditional_py_prompt() {
    local py_color="$cyan"
    if [[ -n "$(condaenv_prompt)$(virtualenv_prompt)" ]]; then
        echo -e "${py_color}($(condaenv_prompt)$(virtualenv_prompt):${py_color}$(py_interp_prompt)) "
    fi
}

function prompt_command() {
    local line1="${green}\w ${white}on ${purple}\h ${reset_color}$(color_parse_git_branch)"
    local line2="${cyan}$(conditional_py_prompt)${green}${prompt_thingy}${reset_color} "
    PS1="\n$line1\n$line2"
}

safe_append_prompt_command prompt_command
