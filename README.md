# CentOS Systemd Jupyter Notebook

Base notebook for running bash in JupyterHub with a CentOS 7 System image.

This is based on https://github.com/jupyter/docker-stacks/tree/ede5987507cfb52a70e0909f321baf4b059c2add/base-notebook


## Usage

Generate a secure access token.
Run the container in privileged mode (it may be possible to run Systemd with lower privileges):

    JUPYTER_TOKEN=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 32)
    docker run -d --name jupyter-notebook -p 8888:8888 --privileged \
        -e JUPYTER_TOKEN=$JUPYTER_TOKEN centos-systemd-jupyter-notebook

Open the notebook server in your browser:

    echo http://localhost:8888/?token=$JUPYTER_TOKEN


## Shell kernel

The Bash kernel is installed.
The default `jovyan` user has passwordless `sudo` rights.
