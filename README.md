# CentOS systemd Jupyter Notebook

[![Binder](https://mybinder.org/badge.svg) Launch on MyBinder](https://mybinder.org/v2/gh/manics/centos-systemd-jupyter-notebook/master?urlpath=lab/tree/notebooks/omero-server-bash.ipynb)

Base notebook for running bash in JupyterHub with a CentOS 7 System image.

This is based on https://github.com/jupyter/docker-stacks/tree/ede5987507cfb52a70e0909f321baf4b059c2add/base-notebook


## Usage

Generate a secure access token.
Run the container:

    JUPYTER_TOKEN=$(env LANG=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 32)
    docker run -d --name jupyter-notebook \
        -p 8888:8888 -p 8080:80 -p 4064:4064 \
        -e JUPYTER_TOKEN=$JUPYTER_TOKEN centos-systemd-jupyter-notebook

Open the notebook server in your browser:

    echo http://localhost:8888/?token=$JUPYTER_TOKEN

Open [`omero-server-bash.ipynb`](notebooks/omero-server-bash.ipynb) in the [`notebooks`](notebooks) directory.


## Shell kernel

The Bash kernel is installed.
The default `jovyan` user has passwordless `sudo` rights.


## Technical notes

systemd normally requires elevated privileges to run inside Docker.
This image uses a [a substitute `systemctl` script](https://github.com/gdraheim/docker-systemctl-replacement) so it can be run as a normal container.
This means the behaviour is not identical to the original systemd/systemctl commands, but it should be adequate for testing with Docker.

**WARNING** If you subsequently upgrade systemd it will overwrite the substitute script.
If you see an error like `Failed to get D-Bus connection: Operation not permitted` this is probably the cause.
Rebuild the container (with `--no-cache` if necessary) so that systemd will be updated before `systemctl` is modified.
