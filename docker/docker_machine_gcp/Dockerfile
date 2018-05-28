FROM alpine 

RUN apk --no-cache add curl python docker
WORKDIR /usr/local
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-201.0.0-linux-x86_64.tar.gz && \
    tar -xvf google-cloud-sdk-201.0.0-linux-x86_64.tar.gz && \
    rm -f google-cloud-sdk-201.0.0-linux-x86_64.tar.gz && \
    cd google-cloud-sdk && ./install.sh -q

ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/google-cloud-sdk/bin

RUN base=https://github.com/docker/machine/releases/download/v0.14.0 && \
    curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine && \
    install /tmp/docker-machine /usr/local/bin/docker-machine

