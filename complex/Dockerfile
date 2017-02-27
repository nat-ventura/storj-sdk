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
ADD complex/package.json ./

# Thanks to the above line, npm install only re-runs if package.json changes
RUN npm install

# Finally add in all of our source files
ADD complex/ ./

# setup.sh allows us to prime complex's configuration with the envrionement the container starts with, i.e. the IP address that gets assigned to it, allowing us to dynamically generate the configuration file at startup
ADD setup.sh /bin/setup.sh

# Our container needs dumb-init to handle PID-1 responsibilities from the linux kernel, wait.sh to make sure the services complex depends on are up before starting, and setup.sh to generate the configuration file for starting storj-complex
ENTRYPOINT ["dumb-init", "--", "/bin/bash", "/bin/wait.sh", "/bin/setup.sh"]

# By default, run storj-complex at startup
CMD ["./bin/storj-complex.js"]
