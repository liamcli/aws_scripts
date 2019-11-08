FROM nvidia/cuda:9.0-cudnn7-runtime # Base Image

# Setup Ubuntu
RUN apt-get update --yes
RUN apt-get install -y make cmake build-essential autoconf libtool rsync ca-certificates git grep sed dpkg curl wget bzip2 unzip llvm libssl-dev libreadline-dev libncurses5-dev libbz2-dev libsqlite3-dev zlib1g-dev mpich htop vim

# Get Miniconda and make it the main Python interpreter
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
RUN bash ~/miniconda.sh -b -p /opt/conda
RUN rm ~/miniconda.sh
ENV PATH /opt/conda/bin:$PATH
RUN conda create -n tf_env python=3.6
RUN echo "source activate tf_env" > ~/.bashrc
ENV PATH /opt/conda/envs/tf_env/bin:$PATH
ENV CONDA_DEFAULT_ENV tf_env

# Install packages
RUN conda install cudatoolkit=9.0 tensorflow-gpu
RUN conda install boto3
RUN pip install -U pip ipython numpy scipy==0.19.1 cloudpickle scikit-image requests click pandas tqdm sklearn

# Copy code repo to container (this bypasses git credentials)
RUN mkdir -p /code/[REPO]
ADD . /code/[REPO] # Container build must be run from top level of repo to get right context.

# Container should have experiment script in root dir
# so you can run experiments with easy command passed
# to container.
COPY run.sh /

