# Base image to start from: https://hub.docker.com/r/nvidia/cuda
ARG CUDA_BASE=nvidia/cuda:11.4.2-cudnn8-runtime-ubuntu20.04
FROM $CUDA_BASE

LABEL maintainer="Gilles Clarisse <gilles.clarisse@student.howest.be>"

ARG USER=gilles
ARG PASSWORD=123

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install required packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt update --yes \
    && apt install --yes --no-install-recommends \
    tini \
    sudo \
    wget \
    && apt clean && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR="/opt/conda"
ENV LANG="C.UTF-8" LC_ALL="C.UTF-8"
ENV PATH="${CONDA_DIR}/bin:${PATH}"

# Add call to conda init script see: https://stackoverflow.com/a/58081608/4413446
# Add new user, create conda dir and set new user as owner
RUN echo 'eval "$(command conda shell.bash hook 2> /dev/null)"' >> /etc/skel/.bashrc \
    && useradd -m -s /bin/bash -G sudo -p "$(openssl passwd -1 ${PASSWORD})" "${USER}"\
    && mkdir -p "${CONDA_DIR}" \
    && chown "${USER}" "${CONDA_DIR}" \
    && sed -r "s#Defaults\s+secure_path\s*=\s*\"?([^\"]+)\"?#Defaults secure_path=\"\1:${CONDA_DIR}/bin\"#" /etc/sudoers | grep secure_path > /etc/sudoers.d/path

USER ${USER}
WORKDIR "/home/${USER}"

# Install and configure Mambaforge
RUN wget --no-hsts --quiet "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-$(uname -m).sh" -O /tmp/miniforge.sh \
    && /bin/bash /tmp/miniforge.sh -b -f -p ${CONDA_DIR} \
    && rm /tmp/miniforge.sh \
    && conda config --system --set auto_update_conda false \
    && conda update --all --quiet --yes \
    && conda clean -afy \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.pyc' -delete 

# Install JupyterLab
RUN mamba install --quiet --yes \
    jupyterlab \
    nb_conda_kernels \
    mamba_gator \
    && mamba clean -afy \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
    && jupyter notebook --generate-config \
    && jupyter lab clean

# Copy start script
COPY start.sh /usr/local/bin/start.sh

# Copy JupyterLab config into container
COPY jupyter_server_config.py /etc/jupyter/

EXPOSE 8888

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start.sh"]