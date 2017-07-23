# Build docker container: docker build -t tf .
# Use docker (CPU): docker run -it tf /bin/bash
# Use docker (GPU): nvidia-docker run -it tf /bin/bash

FROM ubuntu:16.04
MAINTAINER oliv

SHELL ["/bin/bash", "-c"]

WORKDIR /root

RUN apt-get -y update
RUN apt-get -y install -y --no-install-recommends git
RUN git init .
RUN git remote add -t \* -f origin https://github.com/oliviersoares/dotfiles
RUN git checkout master
RUN rm -rf .git
RUN echo "source .bash_me" >> .bash_aliases
RUN bash bin/setup.sh
