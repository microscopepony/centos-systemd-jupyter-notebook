#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -e

if [[ ! -z "${JUPYTERHUB_API_TOKEN}" ]]; then
  # launched by JupyterHub, use single-user entrypoint
  exec /opt/conda/bin/jupyter labhub --ip=0.0.0.0 $JUPYTER_NOTEBOOK_OPTS $@
else
  exec /opt/conda/bin/jupyter lab $JUPYTER_NOTEBOOK_OPTS $@
fi
