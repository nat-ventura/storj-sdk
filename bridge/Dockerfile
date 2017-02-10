FROM node:6.9.1

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 \
 && chmod +x /usr/local/bin/dumb-init

VOLUME ./bridge:/usr/src/app
WORKDIR /usr/src/app
ADD bridge/package.json .
RUN npm install
ADD bridge/ ./

ADD https://raw.githubusercontent.com/Storj/storj-sdk/master/scripts/wait.sh /bin/wait.sh

ENTRYPOINT ["dumb-init", "--", "/bin/bash", "/bin/wait.sh"]
CMD ["./bin/storj-bridge.js"]
#CMD ["/bin/sleep", "6000"]
