FROM ubuntu:22.04
MAINTAINER 4ertovwig <xperious@mail.ru>

ENV RUNLEVEL 1

ARG WORKSPACE="/usr/src"
ARG PROJECT_NAME="asm"
ARG WORKDIRECTORY=${WORKSPACE}/${PROJECT_NAME} 

# Install
RUN \
    apt-get update && \
    apt-get install -y make binutils libc6-dev

# prepare project
RUN mkdir ${WORKDIRECTORY}
COPY .  ${WORKDIRECTORY}/

RUN chmod +x ${WORKDIRECTORY}/run.sh

ENTRYPOINT ["/usr/src/asm/run.sh"]
