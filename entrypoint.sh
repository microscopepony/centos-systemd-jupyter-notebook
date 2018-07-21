#!/bin/bash

set -ex

echo Starting container with arguments "$@"
# Escaping quotes https://unix.stackexchange.com/a/422170
printf "NOTEBOOK_ARGS='%s'\n" "$(echo $@ | sed "s/'/'\"'\"'/g")" > /etc/jupyter/jupyter-notebook-service-env
systemctl environment jupyter-notebook
exec /usr/bin/systemd -vvvv init
