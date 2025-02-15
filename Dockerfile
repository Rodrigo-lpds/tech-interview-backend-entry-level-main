FROM ruby:3.3.1

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
