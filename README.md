# storj-sdk
The Storj Developer Kit

## Setup

### Git Clone
`git clone https://github.com/Storj/storj-sdk.git --recursive`


### Initial Setup
+ `git submodule update --init --recursive`

### Bring up Cluster
+ `docker-compose build`
+ `docker-compose up`

## Pull Latest from Submodules
Pull from tip of remote
+ `git submodule update --recursive --remote`

Pull from latest commit (not what submodules points to)
+ `git submodule update --recursive`
or
+ `git pull --recurse-submodules`

## Pull branch/tag for Submodule
```
cd submodule_directory
git checkout v1.0
cd ..
git add submodule_directory
git commit -m "moved submodule to v1.0"
git push
```

... then another developer would ...

```
git pull
git submodule update
```


### Rebuilding Everything
+ `docker-compose down`
+ `docker-compose rm -f` ?
+ `docker-compose build`
+ `docker-compose up -d`
+ `docker-compose logs -f`

### Rebuild Specific Service (container)
+ Make changes to dockerfile or source
+ `docker-compose up --build [project]` or
  `docker-compose up -d --no-deps [project]`


## Usage
+ Setting upstream (which code repo to use)
+ Setting project versions
+ Pulling current versions of projects in a particular environment (prod, staging)
+ Running certain services locally and pointing to others in other environments
+ Pulling production like data
+ Running load generation against your environment (local or remote)
+ Saving the state of your configuration (push to a branch)
+ Sharing your configuration with someone else (allow another user to create their own branch based on yours or to simply pull the versions of software that you are using without changing anything else)

### Using the CLI aginst local setup
Configuration
-------------
`$ export STORJ_BRIDGE=http://localhost:8080`

Register & Login
-----
`$ storj register`
follow the prompts

You only need to manually approve your user once
`mongo localhost:27017 'command to enable user'`

`$ storj login [username]`
enter your password

Use storj cli as usual

## Spec

### Interface (build.rb)
Notes
-----
+ Name of build.rb should be changed to something like sdk
+ Should use NPM to link the interface file as a binary so you can type [interface_file_name] action

### Dockerfiles

Supporting Containers
---------------------
  + The SDK should contain the base and dependencies dockerfiles

Service Containers
------------------
  + Dockerfile should live in each code repository

### Storj Services
+ Each service repository should be Git submoduled into the SDK


## Implementation

## Tasks
1) Get all services working each with one instance
1.1) Clean up the repo, make sure nothing unwanted is getting comitted and push
1.2) Confirm that the setup instructions work from a clean copy of master
  + probably involve git pull --recurse-submodules
  + for the first time you need to use --init
  + git submodule update --init --recursive
2) Get local file upload/download working
3) Ensure that rebuilding specific containers is resiliant for each one (such that IP's etc... are updated on restart)
4) Work on docker-compose scale for farmers
  + Will need to dynamically and uniquely update the index for each new share instance
  + Will also need to expose itself on a unique port (can docker compose do math with ports?)
5) Cleanup
  + Move ansilary services to a single folder in root
6) Rename and update entry script to assist in the following
  + Bringing the cluster up and down
  + Rebuilding the entire cluster and restarting
  + Run the preconfigured cli from within a docker container (link binary from host? Or launch a container?
  + Watch for changes and automatically (optionally) rebuild and restart anything that has changed
  + Rebuilding a particular container and restarting that service
  + Viewing logs for all or each service
  + List addresses and ports of all services along with service type
7) Convert mongodb container to sharded replicaset with authentication enabled
  + This makes testing more like production
8) Tests
  + Test user creation
  + Test user activation
  + Test file upload
  + Test file download
9) Cleanup / Reset
  + Reset the state of the DB
  + Reset the state of the Farmer


## Issues & Problems to Solve

### Renter Whitelist
  when renter comes up it should expose its renter ID to the farmers somehow so that when they come up they can be put on the whitelist for every farmer
  or we sould find how to disable the requirement of the whitelist


### Making Farmers Reachable from CLI
#### Exposing Farmer to Host
Need to expose farmers IP and port locally (and have it set correctly in its config) so that storj-cli can connect to it. Otherwise we have to run the CLI in a container so that it can reach the network that the farmers are on.

##### VPN
Can use a VPN to connect the two networks. This may require additional setup but could be scripted farily easily on osx in the background using openvpn.

 - https://github.com/wojas/docker-mac-network

##### IP Aliasing
  You can accomplish this with IP aliasing on the host.

  First, add a virtual interface on the host that has a different IP address than the primary interface. We'll call the primary interface eth0 with IP 10.0.0.10, and the virtual interface eth0:1 with IP address 10.0.0.11.

   ifconfig eth0:1 10.0.0.11 netmask 255.255.255.0 up
   Now run the containers and map port 5000 to the corresponding interface. For example:

   docker run -p 10.0.0.10:5000:5000 -name container1 <someimage> <somecommand>
  docker run -p 10.0.0.11:5000:5000 -name container2 <someimage> <somecommand>
  Now you can access each container on port 5000 using different IP addresses externally.
  </somecommand></someimage>

##### Four Ways
  http://blog.oddbit.com/2014/08/11/four-ways-to-connect-a-docker/
  + NAT
  + Linux Bridge Devices
  + Open vSwitch Bridge devices
  + macvlan devices

#### Container host DNS resolution
  + Something like this? https://github.com/bnfinet/docker-dns

#### Container ENV Setup/Config/Customization
  + http://cavaliercoder.com/blog/update-etc-hosts-for-docker-machine.html

#### Running the CLI in a Container
This works but the user experience is not great.

  Wrap running storj cli command in docker container from host
  Replace bin/sleep with something better in cli container?

  + Farmer should expose itself as it's dns name from within docker to avoid issues with IP's ? This may make it unreachable from outside the docker network however as hosts will be trying to resolve the hostname which will not work.


