FROM alpine:3.7 as builder

ENV APP_HOME /app

WORKDIR $APP_HOME
COPY . $APP_HOME

RUN apk add --no-cache \
   gcc \
   g++ \
   make \
   ruby-bundler \
   ruby-dev && \
bundle install 

FROM alpine:3.7
RUN apk add --no-cache \
  ruby-bundler \
  ruby 

ENV APP_HOME /app
ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

WORKDIR $APP_HOME
COPY --from=builder /app ./
COPY --from=builder /usr/lib/ruby  /usr/lib/ruby
COPY --from=builder /usr/bin/puma /usr/bin/puma

CMD ["puma"]
