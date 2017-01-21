FROM node:6.9.1

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 \
 && chmod +x /usr/local/bin/dumb-init

ADD https://raw.githubusercontent.com/retrohacker/docker-wait/master/wait.sh /bin/wait.sh
ADD ./setup.sh /bin/setup.sh

WORKDIR /usr/src/app
ADD storjshare-cli/package.json ./
RUN npm install
ADD storjshare-cli/ ./

ENTRYPOINT ["dumb-init", "--", "/bin/bash", "/bin/wait.sh", "/bin/setup.sh"]
CMD ["./bin/storjshare.js"]
