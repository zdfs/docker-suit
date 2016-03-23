FROM selenium/standalone-chrome
MAINTAINER Zachary Forrest y Salazar <zach.forrest@sonos.com>

USER root

ENV RUBY_BRANCH 2.3
ENV RUBY_VERSION 2.3.0
ENV PHANTOMJS_VERSION 1.9.8

# =========================================================================
# Install Ruby Environment
# =========================================================================

RUN apt-get update
RUN apt-get -y upgrade

RUN apt-get -y install build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev curl git wget ca-certificates libfreetype6 libfontconfig bzip2 rsync ssh xvfb software-properties-common netcat-openbsd

ADD http://cache.ruby-lang.org/pub/ruby/$RUBY_BRANCH/ruby-$RUBY_VERSION.tar.gz /tmp/

RUN cd /tmp && \
  tar -xzf ruby-$RUBY_VERSION.tar.gz && \
  cd ruby-$RUBY_VERSION && \
  ./configure && \
  make && \
  make install && \
  cd .. && \
  rm -rf ruby-$RUBY_VERSION && \
  rm -f ruby-$RUBY_VERSION.tar.gz

RUN gem install bundler --no-ri --no-rdoc

# =========================================================================
# Install Ruby Gems
# =========================================================================

RUN gem install sass

# =========================================================================
# Install Python
# =========================================================================

RUN \
  apt-get update && \
  apt-get install -y python python-dev python-pip python-virtualenv && \
  rm -rf /var/lib/apt/lists/*

# =========================================================================
# Install NodeJS
# =========================================================================

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL warn
ENV NODE_VERSION 4.4.1

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc

CMD [ "node" ]

# =========================================================================
# Install NPM modules
# =========================================================================

RUN npm install grunt-cli karma-cli -g

# =========================================================================
# Install PhantomJS
# =========================================================================

RUN \
  mkdir -p /srv/var && \
  wget -q --no-check-certificate -O /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
  tar -xjf /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 -C /tmp && \
  rm -rf /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 && \
  mv /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/ /srv/var/phantomjs && \
  ln -s /srv/var/phantomjs/bin/phantomjs /usr/bin/phantomjs && \
  apt-get autoremove -y && \
  apt-get clean all
