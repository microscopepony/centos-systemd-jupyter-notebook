#!/bin/bash

set -ex

echo Starting container with arguments "$@"

if [ "$1" == "systemd" ]; then
  shift
  # Escaping quotes https://unix.stackexchange.com/a/422170
  printf "NOTEBOOK_ARGS='%s'\n" "$(echo $@ | sed "s/'/'\"'\"'/g")" > /etc/jupyter/jupyter-notebook-service-env
 systemctl environment jupyter-notebook
  exec /usr/bin/systemd -vvvv init
else
  # JupyterHub spawners may pass strangely quoted arguments so use $*
  exec tini -g -- su jovyan -c "exec /usr/local/bin/start-notebook.sh $*"
fi
