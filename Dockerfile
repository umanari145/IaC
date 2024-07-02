FROM ruby:latest

WORKDIR /home/app

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install