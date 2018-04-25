FROM alpine:3.7

ENV APP_HOME /app
ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

RUN apk add --no-cache \
        gcc \
        g++ \
        make \
        ruby-bundler \
        ruby-dev

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY . $APP_HOME
RUN bundle install

CMD ["puma"]
