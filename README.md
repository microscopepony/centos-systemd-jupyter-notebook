# CentOS Systemd Jupyter Notebook

Base notebook for running bash in JupyterHub with a CentOS 7 System image.

This is based on https://github.com/jupyter/docker-stacks/tree/ede5987507cfb52a70e0909f321baf4b059c2add/base-notebook


## Usage

Run the container in privileged mode (it may be possible to run Systemd with lower privileges):

    docker run -it --rm --name jupyter-notebook -p 8888:8888 --privileged -e JUPYTER_ENABLE_LAB=1 centos-systemd-jupyter-notebook

Log in and get the token:

    docker exec -it jupyter-notebook bash -c "journalctl -u jupyter-notebook | grep -A2 'Copy/paste this URL'"

In the URL change the hostname to localhost and paste into your browser.


## Shell kernel

The Bash kernel is installed.
The default `jovyan` user has passwordless `sudo` rights.
