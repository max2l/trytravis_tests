FROM alpine:3.7

ENV APP_HOME /app
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

RUN apk add --no-cache ruby-bundler make gcc g++ ruby-dev
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
COPY . $APP_HOME
RUN bundle install

CMD ["puma"]
