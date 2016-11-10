#! /bin/bash
if hash mix 2>/dev/null; then
  rm -rf _build/
  RIVET_PORT=${1:-4000} RIVET_IP_ADDRESS=${2:-127.0.0.1} mix release
else
  echo "Command 'mix' not found. Ensure you have elixir installed."
fi
