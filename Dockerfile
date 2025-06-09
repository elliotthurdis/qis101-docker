# Use official 64-bit Debian as the base image
FROM debian:latest

# Use non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

# Allow overriding the Anaconda version at build time
ARG MINICONDA_VERSION=latest
ARG MINICONDA_INSTALLER=Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh
ARG MINICONDA_URL=https://repo.anaconda.com/miniconda/${MINICONDA_INSTALLER}

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  git-all \
  libxcb-cursor0 \
  wget \
  bzip2 \
  ca-certificates \
  build-essential


# RUN wget --quiet ${ANACONDA_URL} -O /tmp/${ANACONDA_INSTALLER} && \
#   bash /tmp/${ANACONDA_INSTALLER} -b -p /opt/conda && \
#   rm /tmp/${ANACONDA_INSTALLER} && \
#   /opt/conda/bin/conda clean -afy

RUN git clone https://github.com/dbiersach/qis101.git

RUN mkdir -p /opt/conda 
RUN wget ${MINICONDA_URL} -O ./miniconda.sh && \
  bash ./miniconda.sh -b -p ./miniconda

# Use bash as login shell so conda can initialize
SHELL ["/bin/bash", "--login", "-c"]

# add conda to PATH
ENV PATH=./miniconda/bin:$PATH

RUN source ./miniconda/bin/activate && conda init --all && \
  conda deactivate && \
  conda update -n base conda -y && \
  conda create -y -n qis101 python=3.12 && \
  conda activate qis101 && \
  conda install -c conda-forge -y mayavi sqlite && \
  conda install -c conda-forge -y matplotlib pyqt pygame && \
  conda install -c conda-forge -y sympy scipy scikit-learn pandas jupyter ipympl && \
  conda install -c conda-forge -y networkx pulp numexpr && \
  conda install -c conda-forge -y selenium webdriver-manager beautifulsoup4

RUN pip install numba numpy==1.26.4 && \
  pip install 'qiskit[all]' qiskit-aer qiskit-algorithms && \
  pip install qiskit-ibm-runtime qiskit-ibm-catalog qiskit-experiments && \
  pip install qiskit-dynamics qiskit-finance qiskit-nature && \
  pip install qiskit-machine-learning qiskit-optimization

# RUN
  # echo 'y'| jupyter lab --generate-config && \
  # echo 'c.ServerApp.use_redirect_file = False' >> ~/jupyter/jupyter_lab_config.py

RUN apt-get clean && rm -rf /var/lib/apt/lists/*


# Set your working directory
# WORKDIR /workspace

# Default command: activate the 'qis101' environment and drop into an interactive shell
CMD ["/bin/bash"]
