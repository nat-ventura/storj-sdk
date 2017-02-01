# storj-sdk
The Storj Developer Kit

## SDK Script
The sdk script in the root directory of this project is a work in progress and is not ready for use.

## Setup / Quick Start

### Check out the Repo
To check out the repository, you'll need to add the `recursive` flag so that all of the services contained within the SDK get populated.

+ `git clone https://github.com/Storj/storj-sdk.git --recursive`

 or if you've already checked out the repo without --recursive, try...

+ `git submodule update --init --recursive`

### Bring up Cluster
To bring up the cluster locally, we use docker-compose.

+ `docker-compose up`

To bring up the cluster in the background
+ `docker-compose up -d`

### Access Cluster
To access your cluster (from OSX) you'll need to install an OpenVPN compatible VPN client such as Tunnelblick.

After you have installed and started your VPN client, browse from the root directory of the repository to the vpn folder and run (or import) the VPN config that was generated after you brought the cluster up. It should be named `storj-local.ovpn`.

To use the local bridge you'll need to either export the STORJ_BRIDGE environment variable or preface your storj command with STORJ_BRIDGE=[local_bridge] replacing [local_bridge] with the bridge address. A script is provided to programatically determine the URL of your local bridge and can be found here: `./scripts/get_local_bridge.sh`. You can go ahead and export the bridge variable in one go like so: `eval export STORJ_BRIDGE=$(./scripts/get_local_bridge.sh)`.

#### Steps

+ Install an OpenVPN compatible VPN client

+ Run or Import the OpenVPN config from `[root_of_sdk]/vpn/storj-local.ovpn`

+ Init your cluster which adds a user, activates it and signs you in by typing `./sdk -i` from the root of the SDK

+ Export the STORJ_BRIDGE environment variable as instructed after running the init

+ Access the bridge as you would normally using your local Storj CLI (core-cli) keeping in mind that you will need to export the STORJ_BRIDGE environment variable in any terminal that you wish to use the local bridge from


## Try it Out
Test your conneciton to the bridge and its supporting services

```
storj add-bucket superawesomebucket
storj list-buckets
```

### Viewing Logs
To watch the logs for all services

+ `docker-compose logs -f`

optionally you can add a service

+ `docker-compose logs -f bridge`

## Developing & Contributing
If you would like to help make Storj better or would like to develop your application on top of the Storj platform, the Storj SDK aims to make this easy by tightening the feedback loop, removing as many requirements for getting started as possible, and allowing users to develop and test without accruing a balance while storing your test files.

### Pull Latest from Submodules
Pull from tip of remote
+ `git submodule update --recursive --remote`

Pull from latest commit (not what submodules points to)
+ `git submodule update --recursive`
or
+ `git pull --recurse-submodules`

### Pull branch/tag for Submodule
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

If you only want to build and not bring up the cluster...
+ `docker-compose build`


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



## SDK Under Heavy Development
Please excuse our mess while we gather our thoughts. This SDK is under active development and may be a bit messy for a moment. At Storj, we love open source and transparency so we keep our thoughts out in the open. Below is a mess of ideas, problems, plans and solutions that we're sorting out and organizing as we go. We love feedback so please feel free to join the #SDK room on our community chat (https://community.storj.io) via the web or RocketChat.

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
9) Take Snapshots of Cluster State
  + Get the state of the cluster the way that you want it
  + Copy the mongodb data somewhere
  + Copy the farmer keys and data somewhere, etc...
9) Cleanup / Reset
  + Reset the state of the DB
  + Reset the state of the Farmer

## Tech Debt / Cleanup
  + It might be better to have the auto user creation and activation be done via JS and use the cli accounts.js actions (register, login, etc...)



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


