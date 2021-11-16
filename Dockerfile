ARG BASE_IMAGE=ubuntu:20.04
FROM "${BASE_IMAGE}"

LABEL maintainer="Gilles Clarisse <gilles.clarisse@student.howest.be>"

ARG MAMBAFORGE_VERSION=
ARG USER=gilles

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install required packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt update -y && apt install -y --no-install-recommends \
    ca-certificates \
    curl \
    tini \
    && apt clean && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR="/opt/conda"
ENV LANG="C.UTF-8" LC_ALL="C.UTF-8"
ENV PATH="${CONDA_DIR}/bin:${PATH}"
ENV SHELL="/bin/bash"

# Add call to conda init script see: https://stackoverflow.com/a/58081608/4413446
# Add new user, create conda dir and set new user as owner
RUN echo 'eval "$(command conda shell.bash hook 2> /dev/null)"' >> /etc/skel/.bashrc \
    && useradd -ms /bin/bash "${USER}"\
    && mkdir -p "${CONDA_DIR}" \
    && chown "${USER}" "${CONDA_DIR}"

# Switch to new user and their home dir 
USER "${USER}"
WORKDIR "/home/${USER}"

# Install and configure Mambaforge
RUN if [ -z "${MAMBAFORGE_VERSION}" ]; then MAMBAFORGE_VERSION=$(curl -s "https://github.com/conda-forge/miniforge/releases/latest/download" 2>&1 | sed 's/^.*download\/\([^\"]*\).*/\1/'); fi \
    && curl -fsSLo /tmp/miniforge.sh \
    "https://github.com/conda-forge/miniforge/releases/download/${MAMBAFORGE_VERSION}/Mambaforge-Linux-$(uname -m).sh" \
    && /bin/bash /tmp/miniforge.sh -b -f -p "${CONDA_DIR}" \
    && rm /tmp/miniforge.sh \
    && conda config --system --set auto_update_conda false \
    && conda update -qy --all \
    && conda clean -afy \
    && find "${CONDA_DIR}" -follow -type f \( -iname '*.a' -o -iname '*.pyc' -o -iname '*.js.map' \) -delete

# Install and configure JupyterLab
RUN mamba install -qy \
    jupyterlab \
    nb_conda_kernels \
    mamba_gator \
    && jupyter lab --generate-config \
    && jupyter lab clean \
    && mamba clean -afy \
    && find "${CONDA_DIR}" -follow -type f \( -iname '*.a' -o -iname '*.pyc' -o -iname '*.js.map' \) -delete

# Copy JupyterLab config into container
COPY jupyter_server_config.py /etc/jupyter/

EXPOSE 8888

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["jupyter", "lab"]