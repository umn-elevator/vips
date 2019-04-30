FROM        ubuntu:18.04

WORKDIR     /tmp/workdir


RUN     apt-get -yqq update && \
        apt-get --no-install-recommends -yqq install software-properties-common && \
        rm -rf /var/lib/apt/lists/*

RUN     add-apt-repository ppa:dhor/myway && \
        apt-get -yqq update && \
        apt-get --no-install-recommends -yqq install libvips42 libvips-tools openslide-tools && \
        rm -rf /var/lib/apt/lists/*

MAINTAINER  Colin McFadden <mcfa0086@umn.edu>
WORKDIR     /scratch/
CMD         ["--help"]
ENTRYPOINT  ["vips"]
ENV         LD_LIBRARY_PATH=/usr/local/lib
