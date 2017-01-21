FROM node:6.9.1

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 \
 && chmod +x /usr/local/bin/dumb-init

WORKDIR /usr/src/app
ADD complex/package.json ./
RUN npm install
ADD complex/ ./
ADD setup.sh /bin/setup.sh

ADD https://raw.githubusercontent.com/retrohacker/docker-wait/master/wait.sh /bin/wait.sh

ENTRYPOINT ["dumb-init", "--", "/bin/bash", "/bin/wait.sh", "/bin/setup.sh"]
CMD ["./bin/storj-complex.js"]
