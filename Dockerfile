FROM ruby:3.1.6-bookworm
LABEL maintainer "gavin zhou <gavin.zhou@gmail.com>"

# gpg keys listed at https://github.com/nodejs/node#release-keys
RUN set -ex \
  && for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    141F07595B7B3FFE74309A937405533BE57C7D57 \
    74F12602B6F1C4E913FAA37AD3A89613643B6201 \
    61FC681DFB92A079F1685E77973F295594EC4689 \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
  ; do \
    gpg --keyserver hkps://keys.openpgp.org --recv-keys "$key" ; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 12.13.0

RUN set -ex \
  && ARCH=`uname -m` \
  && if [ "$ARCH" = "aarch64" ]; then \
       curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-arm64.tar.xz" \
       && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
       && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
       && grep " node-v$NODE_VERSION-linux-arm64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
       && tar -xJf "node-v$NODE_VERSION-linux-arm64.tar.xz" -C /usr/local --strip-components=1 \
       && rm "node-v$NODE_VERSION-linux-arm64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \
     else \
       curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
       && curl -SLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
       && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
       && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
       && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
       && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \
     fi

# https://github.com/nodejs/node-gyp/blob/main/docs/Force-npm-to-use-global-node-gyp.md#linux-and-macos
RUN npm install -g node-gyp@9.3.1
RUN npm config set node_gyp $(npm prefix -g)/lib/node_modules/node-gyp/bin/node-gyp.js
