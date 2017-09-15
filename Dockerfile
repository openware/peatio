FROM ruby:2.2.1

RUN apt-get update
RUN apt-get -y install imagemagick gsfonts
