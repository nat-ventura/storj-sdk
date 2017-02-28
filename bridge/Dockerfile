# Use the latest Node v6 (LTS) release
FROM node:6

# We use dumb-init since Node.js is pretty terrible at running as PID 1
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 \
 && chmod +x /usr/local/bin/dumb-init

# wait.sh forces our app to wait for other containers to come up before starting
RUN wget -O /bin/wait.sh https://raw.githubusercontent.com/Storj/storj-sdk/master/scripts/wait.sh

# We will run our application from /usr/src/app to be a good linux citizen
WORKDIR /usr/src/app

# Cache node_modules
ADD bridge/package.json .

# Thanks to the above line, npm install only re-runs if package.json changes
RUN npm install

# Finally add in all of our source files
ADD bridge/ ./

# Pass everything through dumb-init and wait.sh first, making sure our process handles the responsibilities of PID 1 and waits for services it depends on to start before coming up.
ENTRYPOINT ["dumb-init", "--", "/bin/bash", "/bin/wait.sh"]

# The default command this container will run is the bridge, but the user can pass in their own commands which get handled by wait.sh and dumb-init.
CMD ["./bin/storj-bridge.js"]
