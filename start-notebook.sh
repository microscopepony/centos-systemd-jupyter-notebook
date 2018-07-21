#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -ex

if [[ ! -z "${JUPYTERHUB_API_TOKEN}" ]]; then
  # launched by JupyterHub, use single-user entrypoint
  if [[ "$NOTEBOOK_ARGS $@" != *"--ip="* ]]; then
    # set default ip to 0.0.0.0
    NOTEBOOK_ARGS="--ip=0.0.0.0 $NOTEBOOK_ARGS"
  fi
  exec /opt/conda/bin/jupyter labhub $NOTEBOOK_ARGS $@
else
  exec /opt/conda/bin/jupyter lab $NOTEBOOK_ARGS $@
fi
