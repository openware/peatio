ARG RUBY_VERSION
FROM ruby:${RUBY_VERSION}

RUN apt-get update
RUN apt-get -y install imagemagick gsfonts libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev

ARG PHANTOM_JS="phantomjs-2.1.1-linux-x86_64"
RUN cd /root \
    && wget -q https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2 \
    && tar xvjf $PHANTOM_JS.tar.bz2 \
    && mv $PHANTOM_JS /usr/local/share \
    && ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin

RUN gem install bundler
RUN useradd -u 1000 -m web
VOLUME /home/web
USER web
ENV HOME="/home/web" \
    GEM_HOME="/home/web/.gem" \
    BUNDLE_PATH="/home/web/.gem" \
    PATH="${PATH}:/home/web/.gem/bin" \
    BUNDLE_APP_CONFIG="/home/web/.gem" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8"

WORKDIR "/home/web"
