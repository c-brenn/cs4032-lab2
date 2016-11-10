#! /bin/bash
if hash mix 2>/dev/null; then
  if [ -e rel/rivet/bin/rivet ]; then
    rel/rivet/bin/rivet foreground
  else
    echo "Compiled project not found. Plead run compile.sh"
  fi
else
  echo "Command 'mix' not found. Ensure you have elixir installed."
fi
