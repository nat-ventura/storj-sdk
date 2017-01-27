FROM node:6.9.1

RUN apt-get update \
 && apt-get install -y --force-yes --no-install-recommends \
      procmail \
 && rm -rf /var/lib/apt/lists/*;

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 \
 && chmod +x /usr/local/bin/dumb-init

# Upstream & Credit - https://github.com/retrohacker/docker-wait/blob/master/wait.sh
ADD https://raw.githubusercontent.com/Storj/storj-sdk/master/scripts/wait.sh /bin/wait.sh
ADD ./setup.sh /bin/setup.sh

WORKDIR /usr/src/app
ADD storjshare-daemon/package.json ./
RUN npm install
RUN mkdir /share
ADD storjshare-daemon/ ./
ADD TRUSTED_KEYS ./node_modules/storj-lib/lib/

ENTRYPOINT ["dumb-init", "--", "/bin/bash", "/bin/wait.sh", "/bin/setup.sh", "bin/storjshare.js start -c /root/config.json"]
