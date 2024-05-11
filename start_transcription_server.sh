# my_script.sh

# Get the directory where this script is located
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

# Check if virtual environment directory exists in the script's directory
if [ -d "$SCRIPT_DIR/.venv" ]; then
  # Activate virtual environment
  source "$SCRIPT_DIR/.venv/bin/activate"
else
  echo "Error: Virtual environment not found in $SCRIPT_DIR!"
  exit 1
fi

# Check if target script exists in the script's directory
if [ -f "$SCRIPT_DIR/run_server.py" ]; then
  # Run the target script with arguments
  python3 "$SCRIPT_DIR/run_server.py" --port 9090 --backend faster_whisper
else
  echo "Error: run_server.py not found in $SCRIPT_DIR!"
  exit 1
fi

