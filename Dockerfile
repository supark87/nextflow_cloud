
FROM ubuntu:20.10

#COPY . /data/
#WORKDIR /data/

# fastqc requires java
RUN apt-get update && apt-get install -y \
  curl \
  unzip \
  perl \
  openjdk-11-jre-headless

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git

RUN apt-get install -y wget
#RUN git clone https://github.com/supark87/coregenescheme.git

RUN apt-get update && apt-get install -y fastqc
RUN apt-get update && apt-get install -y bowtie2
RUN apt-get update && apt-get install -y freebayes


RUN apt-get update \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip
RUN pip3 install matplotlib 

## -- install velvet/oases with long kmers -- ##

ENV BBMAP_VERSION 38.20
ENV BBMAP_DIR /usr/local/bbmap

WORKDIR /usr/local
RUN set -eux; \
       wget -O bbmap.tar.gz https://sourceforge.net/projects/bbmap/files/BBMap_${BBMAP_VERSION}.tar.gz/download \
    && tar -zxf bbmap.tar.gz \
    && rm bbmap.tar.gz

ENV PATH ${BBMAP_DIR}:${PATH}
# (base) ➜  docker git:(main) ✗ docker tag my-image supark87/my-image:v3
# (base) ➜  docker git:(main) ✗ docker push supark87/my-image:v3

