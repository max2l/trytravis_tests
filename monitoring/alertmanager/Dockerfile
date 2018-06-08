FROM alpine:3.7 as alertmanager

RUN apk add --no-cache git go make musl-dev
ENV GOPATH /usr/src
 
WORKDIR $GOPATH/src/github.com/prometheus
RUN git clone https://github.com/prometheus/alertmanager.git
RUN cd alertmanager &&  make build

FROM alpine:3.7
RUN apk add --no-cache ca-certificates
RUN mkdir /etc/alertmanager
COPY --from=alertmanager /usr/src/src/github.com/prometheus/alertmanager/alertmanager /alertmanager
COPY config.yml /etc/alertmanager/
CMD [ "/alertmanager", "--config.file=/etc/alertmanager/config.yml" ]

