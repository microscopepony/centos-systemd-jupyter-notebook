FROM centos:7
MAINTAINER spli@dundee.ac.uk
# Based on
# https://github.com/jupyter/docker-stacks/blob/ede5987507cfb52a70e0909f321baf4b059c2add/base-notebook/Dockerfile

RUN yum install -q -y \
    wget \
    bzip2 \
    sudo

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.18.0/tini && \
    echo "12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=jovyan \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

# Create jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN useradd -m -s /bin/bash -N -u $NB_UID -g users $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR

USER $NB_UID

ENV MINICONDA_VERSION 4.5.4
RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "a946ea1d0c4a642ddf0c3a26a18bb16d *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda config --system --prepend channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    $CONDA_DIR/bin/conda install --quiet --yes conda="${MINICONDA_VERSION%.*}.*" && \
    $CONDA_DIR/bin/conda update --all --quiet --yes && \
    conda clean -tipsy && \
    rm -rf /home/$NB_USER/.cache/yarn

# Install Jupyter Notebook and Hub
RUN conda install --quiet --yes \
    'notebook=5.5.*' \
    'jupyterhub=0.8.*' \
    'jupyterlab=0.32.*' && \
    conda clean -tipsy && \
    jupyter labextension install @jupyterlab/hub-extension@^0.8.1 && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn

# Bash kernel https://github.com/takluyver/bash_kernel
RUN pip install bash-kernel==0.7.1 && \
    python -m bash_kernel.install

# Arbitrary web service proxy https://github.com/jupyterhub/nbserverproxy
RUN conda install --quiet --yes nbserverproxy && \
    jupyter serverextension enable --py nbserverproxy

EXPOSE 80 4063 4064 8888

# # Changes the console so <enter> runs a command instead of <shift-enter>
# COPY jupyterlab-console-enter.json /home/$NB_USER/.jupyter/lab/user-settings/@jupyterlab/shortcuts-extension/plugin.jupyterlab-settings

COPY notebooks/ /notebooks/
COPY README.md /

USER root

# https://github.com/gdraheim/docker-systemctl-replacement
# Upgrade systemd now to reduce likelihood of it being upgraded and
# overwriting this replacement script
# Create /run/systemd/system to fool Ansible into thinking systemd is running
ARG SYSTEMCTL=https://raw.githubusercontent.com/manics/docker-systemctl-replacement/devel/files/docker/systemctl.py
#ARG SYSTEMCTL=https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py
RUN yum update -y -q systemd && \
    curl -o /usr/bin/systemctl $SYSTEMCTL && \
    ln -s /usr/bin/systemctl /usr/bin/systemd && \
    mkdir -p /run/systemd/system

COPY entrypoint.sh start-notebook.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/
COPY jupyter-notebook.service /etc/systemd/system/

# Fix permissions, configure container startup
RUN chown -R $NB_USER:$NB_GID /home/$NB_USER/ /notebooks/ && \
    echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook && \
    ln -s /etc/systemd/system/jupyter-notebook.service /etc/systemd/system/multi-user.target.wants/jupyter-notebook.service

# USER $NB_UID
# ENTRYPOINT ["/usr/local/bin/tini", "-g", "--"]
# CMD ["/usr/local/bin/start-notebook.sh"]
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []
