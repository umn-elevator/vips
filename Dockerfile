FROM        ubuntu:18.04 as base

FROM        base as build

WORKDIR     /tmp/workdir

RUN     apt-get -yqq update && \
        apt-get install -yqq --no-install-recommends ca-certificates && \
        rm -rf /var/lib/apt/lists/*

RUN     apt-get -yqq update && \
        apt-get --no-install-recommends -yqq install curl unzip make autoconf automake cmake g++ gcc software-properties-common && \
        rm -rf /var/lib/apt/lists/*
        
# RUN     add-apt-repository ppa:dhor/myway && \
# RUN        apt-get -yqq update && \
#         apt-get --no-install-recommends -yqq install wget openslide-tools libopenslide-dev  libgsf-1-dev libtiff-dev libjpeg-turbo8-dev zlib1g-dev libexpat1 libexpat1-dev && \
#         rm -rf /var/lib/apt/lists/*

RUN     BUILD_PACKAGES='curl unzip make autoconf automake cmake g++ gcc build-essential' && \
        add-apt-repository ppa:strukturag/libheif && \
        add-apt-repository ppa:strukturag/libde265 && \
        apt-get -yqq update && \
        apt-get --no-install-recommends -yqq install $BUILD_PACKAGES && \
        apt-get -y install --no-install-recommends wget libde265-0 libheif1 libheif-dev libexif-dev libopenslide-dev libgsf-1-dev libopenjp2-7-dev libexpat1-dev libjbig-dev  zlib1g-dev libtiff5-dev libpng16-16 libpng-dev libjpeg-turbo8 libjpeg-turbo8-dev libjbig2dec0 libwebp6 libwebp-dev libgomp1 libwebpmux3 pkg-config libbz2-dev libxml2-dev ghostscript && \
        DIR=/tmp/imagemagick && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -L -o ${DIR}/7.0.8-39.tar.gz https://github.com/ImageMagick/ImageMagick/archive/7.0.8-39.tar.gz && \
        tar -zxvf ${DIR}/7.0.8-39.tar.gz  && \
        cd ${DIR}/ImageMagick-7.0.8-39 && \
        ./configure --with-heic --with-xml=yes && \
        make -j4 && \
        make install && \
        rm -rf ${DIR}


ARG VIPS_VERSION=8.10.6
ARG VIPS_URL=https://github.com/libvips/libvips/releases/download


RUN wget ${VIPS_URL}/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz \
        && tar xf vips-${VIPS_VERSION}.tar.gz \
        && cd vips-${VIPS_VERSION} \
        && ./configure \
        && make V=0 \
        && make install 


FROM base as release

WORKDIR     /tmp/workdir

RUN     apt-get -yqq update && \
        apt-get --no-install-recommends -yqq install software-properties-common && \
        rm -rf /var/lib/apt/lists/*

RUN     add-apt-repository ppa:strukturag/libheif && \
        add-apt-repository ppa:strukturag/libde265 && \
        apt-get -y install --no-install-recommends libheif1 libopenjp2-7 libgsf-1-114  libjbig2dec0 libexif-dev libde265-0 libheif1 openslide-tools libpng16-16 libopenjp2-7 libjbig0 libtiff5 libjpeg-turbo8 libwebp6 libgomp1 libbz2-1.0 libwebpmux3 libwebp-dev libxml2-dev && \
        rm -rf /var/lib/apt/lists/*

COPY        --from=build /usr/local/bin /usr/local/bin
COPY        --from=build /usr/local/lib /usr/local/lib
COPY        --from=build /usr/local/etc /usr/local/etc



MAINTAINER  Colin McFadden <mcfa0086@umn.edu>
WORKDIR     /scratch/
CMD         ["--help"]
ENTRYPOINT  ["vips"]
ENV         LD_LIBRARY_PATH=/usr/local/lib
