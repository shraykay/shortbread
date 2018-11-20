FROM ruby:2.2.2

WORKDIR /app

ADD ./Gemfile /app/Gemfile
ADD ./Gemfile.lock /app/Gemfile.lock

RUN gem install bundler && \
  bundle config mirror.https://rubygems.org && \
  bundle install

ADD . /app/