#!/bin/bash
# Get the directory where this script is located
echo "**********************************"
echo "start_stt_server.sh is now running"
echo "**********************************" 
SCRIPT_DIR=$(dirname "$0")
echo "SCRIPT_DIR = $SCRIPT_DIR"
VENV_DIR="${SCRIPT_DIR}/.venv"
echo "VENV_DIR = $VENV_DIR"
source "${VENV_DIR}/bin/activate"

# Function to recursively kill child processes
kill_children() {
    local pid=$1
    local children=$(pgrep -P "$pid")

    for child_pid in $children; do
        kill_children "$child_pid"
        kill "$child_pid"
    done
}


# Default value for NURNIEVOX_DIR
NURNIEVOX_DIR=""

# Path to store PID of server process
PID_FILE="/tmp/stt_server.pid"

# Check if .NURNIEVOX_DIR file exists
if [ -f "$SCRIPT_DIR/.NURNIEVOX_DIR" ]; then
    # Read the path from the file and store it in a variable
    NURNIEVOX_DIR=$(<"$SCRIPT_DIR/.NURNIEVOX_DIR")
    echo "NURNIEVOX_DIR read from .NURNIEVOX_DIR: $NURNIEVOX_DIR"
else
    echo "Error: .NURNIEVOX_DIR file not found"
    exit 1
fi


# Check if NURNIEVOX_DIR is provided
if [ -z "$NURNIEVOX_DIR" ]; then
  echo "Error: NURNIEVOX_DIR not provided"
  usage
fi

echo "Got NURNIEVOX_DIR: $NURNIEVOX_DIR"
echo "STARTING TRANSCRIPTION SERVER in $SCRIPT_DIR"

# Check if target script exists in the script's directory
if [ -f "$SCRIPT_DIR/run_server.py" ]; then
  # Run the target script with arguments and get its PID
  python3 "$SCRIPT_DIR/run_server.py" --port 9090 --backend faster_whisper &
  # Store the PID in the PID file
  PID=$!
  echo "PID of STT server is: ${PID}"
  echo ${PID} > "$PID_FILE" # saves it in case another process needs it
else
  echo "Error: run_server.py not found in $SCRIPT_DIR!"
  exit 1
fi

echo "*****************************************"
echo
echo "Press <Enter> to exit and kill STT server"
echo
echo "*****************************************"

read
echo
sleep 1 

if ps -p $PID > /dev/null; then
    # Kill the server process and all its child processes
    kill ${PID}
    echo "STT server with PID $PID and its child processes have been successfully killed."
else
    echo "STT server with PID $PID is not running."
fi

kill_children "${PID}"
