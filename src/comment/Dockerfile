FROM alpine:3.7

ENV APP_HOME /app
ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments
WORKDIR $APP_HOME
COPY . $APP_HOME

RUN apk add --no-cache \
        gcc \
        g++ \
        make \
        ruby-bundler \
        ruby-dev && \
    bundle install && \
    apk del \
        gcc \
        g++ \ 
        make

CMD ["puma"]
