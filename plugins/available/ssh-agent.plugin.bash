# cite ssh-agent-plugin
# about-plugin 'Automatically start ssh-agent'


load-fingerprints-and-ids () {
    export fingerprints=

    while read id_file; do
        fingerprints="\"$id_file\" $(key-to-fingerprint "$id_file")$fingerprints"
    done < <(ls ~/.ssh/id* | grep -v '\.pub$')

    echo -e $fingerprints
}

key-to-fingerprint() {
    local key="$1"
    ssh-keygen -lf "$key" | cut -d ' ' -f 2
}

get-agent-fingerprints() {
    ssh-add -l 2>/dev/null | cut -d ' ' -f 2
}


start-agent-if-unstarted() {
    if [[ -z "$SSH_AGENT_PID" ]] && ps ax | grep -q $SSH_AGENT_PID &> /dev/null; then
        eval "$(ssh-agent)"
    fi
}

add-identities () {
    load-fingerprints-and-ids | while read fingerprint_and_id; do 
        set -- $fingerprint_and_id
        local id_file="$1"
        local fingerprint="$2"
        if ! get-agent-fingerprints | grep -q $fingerprint; then
            ssh-add $id_file
        fi
    done
}


start-agent-if-unstarted
add-identities
        
