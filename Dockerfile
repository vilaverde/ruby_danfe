FROM ruby:2.3.1

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

RUN mkdir /ruby-danfe

WORKDIR /ruby-danfe

ADD Gemfile /ruby-danfe/Gemfile

ADD Gemfile.lock /ruby-danfe/Gemfile.lock

ADD ruby_danfe.gemspec /ruby-danfe/ruby_danfe.gemspec

ADD lib/ruby_danfe/version.rb /lib/ruby_danfe/version.rb

ADD version.rb /ruby-danfe/version.rb

RUN gem install bundler --version=1.15.2

RUN bundle install

ADD . /ruby-danfe
