FROM alpine:3.7 as telegraf

RUN apk add --no-cache go git make g++
RUN git clone https://github.com/influxdata/telegraf.git
WORKDIR /telegraf
ENV GOPATH /telegraf
RUN go get -d github.com/influxdata/telegraf
RUN cd $GOPATH/src/github.com/influxdata/telegraf && make

FROM alpine:3.7
COPY --from=telegraf /telegraf/src/github.com/influxdata/telegraf/telegraf /telegraf
RUN mkdir /etc/telegraf
COPY telegraf.conf /etc/telegraf
CMD /telegraf

