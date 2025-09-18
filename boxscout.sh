#!/usr/bin/env bash

APP_NAME="BoxScout"

COMMANDS=("sudo nmap -T4 -sn 192.168.50.0/24" "ls -la; sleep 2")

# Function to resolve absolute script path
get_script_path() {
    if [[ $0 == /* ]]; then
        echo "$0"
    else
        echo "$(pwd)/$0"
    fi
}

main() {

    # Check whether we are running in tmux.
    # If not, start a new session with this script and attach.
    if [ -z "$TMUX" ]; then
        SESSION="${APP_NAME}"
        SCRIPT_PATH=$(get_script_path)

        tmux new-session -d -s "$SESSION" 
        tmux send-keys -t "$SESSION" "bash $SCRIPT_PATH" C-m
        tmux attach -t "$SESSION"
        exit 0
    fi

    i=0
    while true; do
        if [[ $i -ge ${#COMMANDS[@]} ]]; then
            break
        fi
        # Prompt for user input
        # read -r -p "Enter a command to run (or 'quit' to exit): " USER_INPUT

        # Handle exit
        if [ "$USER_INPUT" = "quit" ]; then
            echo "Exiting..."
            break
        fi

        # Generate unique channel name
        CHANNEL="channel_$(date +%s)_$RANDOM"

        # Determine the command based on input (example: echo it back, or customize logic)
        # cmd="$USER_INPUT"  # Replace with your logic, e.g., case "$USER_INPUT" in ... esac
        cmd=${COMMANDS[i]}

        # Split window, run cmd in new pane, and have it self-kill when done
        tmux split-window -h -p 70 -PF "#{pane_id}" "$cmd; sleep 2; tmux wait-for -S $CHANNEL" > /dev/null

        # Re-select control pane to keep focus here
        tmux wait-for "$CHANNEL"

        # Optional: Reset layout or notify
        echo "Command finished. Ready for next input."
        ((i++))
    done

    # Clean up session on exit
    tmux kill-session
}

main "$@"
