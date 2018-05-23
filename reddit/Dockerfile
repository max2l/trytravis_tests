FROM alpine:latest
RUN apk --no-cache add ruby ruby-dev ruby-bundler build-base

ENV PUMA_HOME /app
WORKDIR $PUMA_HOME

ADD . $PUMA_HOME
RUN bundle install 

CMD ["puma"]
