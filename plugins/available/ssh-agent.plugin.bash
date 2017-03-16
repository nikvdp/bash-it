cite about-plugin
about-plugin 'Automatically start ssh-agent'

dohdoh() {
    while read id_file; do
        fingerprints="$id_file $(key-to-fingerprint "$id_file")\n$fingerprints"
    done < <(ls ~/.ssh/id* | grep -v '\.pub$')

    echo -e $fingerprints | sed '/^$/d'
}

load-fingerprints-and-ids () {
    export fingerprints=
    local pw

    while read id_file; do
        read -sp "Password for key $id_file: " pw
        fingerprints="$id_file $(key-to-fingerprint "$id_file")\n$fingerprints"
    done < <(ls ~/.ssh/id* | grep -v '\.pub$')

    echo -e $fingerprints | sed '/^$/d'
}

key-to-fingerprint() {
    local id_file="$1"
    if [[ ! -f "$id_file.pub" ]]; then
        read -p "No public key found for key $id_file. Try to create one? (y/n)" create
        [[ create == [yY]* ]] && {
            get-public-key-from-private "$id_file" > "$id_file.pub"
            chmod 600 "$id_file.pub"
        }
    fi
    ssh-keygen -lf "$id_file.pub" | cut -d ' ' -f 2
}

get-public-key-from-private() {
    local id_file="$1"
    ssh-keygen -yf "$id_file" 
}

get-agent-fingerprints() {
    ssh-add -l 2>/dev/null | cut -d ' ' -f 2 
}


start-agent-if-unstarted() {
    local hostname="$(hostname | sed 's/\..*//')"

    # if we found ssh auth settings from a previous run, use those
    if [[ -f ~/.ssh/bash-it-ssh-agent ]]; then
        source ~/.ssh/bash-it-ssh-agent &>/dev/null
    fi

    # start a new agent if agent is not running at saved pid
    if ! kill -0 $SSH_AGENT_PID &> /dev/null; then
        ssh-agent > ~/.ssh/bash-it-ssh-agent
        source ~/.ssh/bash-it-ssh-agent &>/dev/null
    fi
}

add-identities () {
    load-fingerprints-and-ids | while read fingerprint_and_id; do 
        set -- $fingerprint_and_id
        local id_file="$1"
        local fingerprint="$2"
        if ! get-agent-fingerprints | grep -q $fingerprint; then
            local optional_params=
            if [[ "$(uname)" == "Darwin" ]]; then
                optional_params="-K "
            fi
            ssh-add $optional_params $id_file &> /dev/null
        fi
    done

    # re-run ssh-add, so that it's exit code becomes this function's
    # exit code. if ssh-add's exit code is non-zero that means that either
    # we didn't add any ids or that ssh-add couldn't connect to the agent
    ssh-add -l &> /dev/null
}


# if agent is already running then just try to add identities to it. If that doesn't work
# then attempt to start it and then add identities
add-identities || {
    start-agent-if-unstarted &&
        add-identities
}

        
