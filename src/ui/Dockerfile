FROM alpine:3.7 as builder

ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . $APP_HOME

RUN apk add --no-cache \
        ruby-bundler\
        ruby-dev \
        g++ \
        gcc \
        make && \
    bundle install

FROM alpine:3.7
RUN apk add --no-cache \
      ruby-bundler

ENV APP_HOME /app
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

WORKDIR $APP_HOME
COPY --from=builder /app ./
COPY --from=builder /usr/lib/ruby  /usr/lib/ruby
COPY --from=builder /usr/bin/puma /usr/bin/puma

CMD ["puma"]

