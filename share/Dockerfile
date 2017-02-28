# Use the latest Node v6 (LTS) release
FROM node:6

# Procmail provides lockfile, because linux. We need lockfile for persisting farmer data to a mounted volume in Docker using setup.sh. So we install procmail to get lockfile and then whack all of the downloaded cache files for aptitude, keeping our final image small.
RUN apt-get update \
 && apt-get install -y --force-yes --no-install-recommends \
      procmail \
 && rm -rf /var/lib/apt/lists/*;

# We use dumb-init since Node.js is pretty terrible at running as PID 1
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 \
 && chmod +x /usr/local/bin/dumb-init

# wait.sh forces our app to wait for other containers to come up before starting
RUN wget -O /bin/wait.sh https://raw.githubusercontent.com/Storj/storj-sdk/master/scripts/wait.sh

# We will run our application from /usr/src/app to be a good linux citizen
WORKDIR /usr/src/app

# Cache node_modules
ADD storjshare-daemon/package.json ./

# Thanks to the above line, npm install only re-runs if package.json changes
RUN npm install

# Finally add in all of our source files
ADD storjshare-daemon/ ./

# setup.sh allows us to prime shares' configuration with the envrionement the container starts with, i.e. the IP address that gets assigned to it, allowing us to dynamically generate the configuration file at startup
ADD ./setup.sh /bin/setup.sh

# TODO: Move to docker-compose
ADD TRUSTED_KEYS ./node_modules/storj-lib/lib/

# Pass everything through dumb-init and wait.sh first, making sure our process handles the responsibilities of PID 1 and waits for services it depends on to start before coming up.
ENTRYPOINT ["dumb-init", "--", "/bin/bash", "/bin/wait.sh", "/bin/setup.sh"]

# By default we will start the storj-share daemon using a configuration file from /etc/storj/share.json, note that this starts a daemon process so the container will immediately exit, you need to run something like 'tail' similar to what /bin/setup.sh does if you decide to use another entrypoint
CMD ["./bin/storjshare.js daemon && ./bin/storjshare.js start -c /root/.config/storjshare/config"]
