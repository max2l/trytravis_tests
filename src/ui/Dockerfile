FROM alpine:3.7

ENV APP_HOME /app
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
WORKDIR $APP_HOME
COPY . $APP_HOME

RUN apk add --no-cache \
        ruby-bundler\
        ruby-dev \
        g++ \
        gcc \
        make && \
    bundle install && \
    apk del \ 
        g++ \
        gcc \
        make 

CMD ["puma"]
