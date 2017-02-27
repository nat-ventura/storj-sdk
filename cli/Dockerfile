# Use the latest Node v6 (LTS) release
FROM node:6

# We use dumb-init since Node.js is pretty terrible at running as PID 1
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 \
 && chmod +x /usr/local/bin/dumb-init

# We will run our application from /usr/src/app to be a good linux citizen
WORKDIR /usr/src/app

# Cache node_modules
ADD core-cli/package.json .

# Thanks to the above line, npm install only re-runs if package.json changes
RUN npm install

# Finally add in all of our source files
ADD core-cli/ ./

WORKDIR /usr/src/data

# We make sure all commands go through dumb-init so they run as PID 1 properly
ENTRYPOINT ["dumb-init", "--"]

# Uncomment this to use the storj cli directly via docker
# ENTRYPOINT ["dumb-init", "--", "/usr/src/app/bin/storj.js"]

# This forces docker-compose to rebuild storj-cli in case you have code changes, but when it runs it does nothing
CMD ["exit", "0"]
