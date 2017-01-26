FROM node:6.9.1

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 \
 && chmod +x /usr/local/bin/dumb-init

WORKDIR /usr/src/app
ADD core-cli/package.json .
RUN npm install
ADD core-cli/ ./

ENV STORJ_BRIDGE http://bridge:8080

WORKDIR /usr/src/data

CMD ["/bin/sleep", "infinity"]
#ENTRYPOINT ["dumb-init", "--", "/usr/src/app/bin/storj.js"]
#CMD ["--help"]
