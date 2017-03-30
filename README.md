Storj Developer Kit
===================

The Storj Developer Kit is designed to enable both Team Members at Storj Labs and Community Members alike to quickly set up a fully working, complete and consistent environment with which to develop, test and experiment.

## Setup

### Dependencies

#### Required

+ A VPN client (see below under Access Cluster)
+ jq ( `apt-get install jq` or `brew install jq` )
+ expect ( `apt-get install expect` or `brew install expect` )

#### Optional
+ Ruby ( this is temporary ) - Required to use the ./sdk script
+ NodeJS v6.9.5 or Greater - Required to run the storj cli locally

### SDK Script (./sdk)
The `sdk` script wraps most of the functionality that you will need when using docker, docker-compose and vpn for these services.

### 1) Check out the Repo
To check out the repository, you'll need to add the `recursive` flag so that all of the services contained within the SDK get populated.

+ `git clone https://github.com/Storj/storj-sdk.git --recursive`

 or if you've already checked out the repo without --recursive, try...

+ `git submodule update --init --recursive`

### 2) Bring up Cluster
To bring up the cluster locally, we use docker-compose.

+ `docker-compose up`

To bring up the cluster in the background
+ `docker-compose up -d`

### 3) Access Cluster
To access your cluster (from OSX) you'll need to install an OpenVPN compatible VPN client.

+ [Tunnelblick](https://tunnelblick.net/downloads.html)
+ [Viscosity](https://www.sparklabs.com/viscosity/download/)

After you have installed and started your VPN client, browse from the root directory of the repository to the vpn folder and run (or import) the VPN config that was generated after you brought the cluster up. It should be named `storj-local.ovpn`.

#### Local SSL
To access services locally over SSL, you will need to set hostnames for them in your local hosets file. The process has been scripted which can be run from the root of the storj-sdk as follows:

`./scripts/set_host_entries.sh`

#### Bridge
[https://bridge-ssl-proxy](https://bridge-ssl-proxy)

#### Bridge GUI
[https://bridge-gui-ssl-proxy](https://bridge-gui-ssl-proxy)

##### Non SSL
[http://bridge](http://bridge)

Quick
=====

From the root of the sdk, run the following command:
`. scripts/setbr`

Manual
======
To use the local bridge you'll need to either export the STORJ_BRIDGE environment variable or preface your storj command with STORJ_BRIDGE=[local_bridge] replacing [local_bridge] with the bridge address.

A script is provided to programatically determine the URL of your local bridge and can be found here:
`./scripts/get_local_bridge.sh`.

You can go ahead and export the bridge variable in one go like so:

`eval export STORJ_BRIDGE=$(./scripts/get_local_bridge.sh)`.
This is what the `setbr` script from above does.

##### SSL
To access the local bridge via ssl, you will need to have run the `set_host_entries.sh` script. You should then be able to use `https://bridge-ssl-proxy` in place of the address obtained by the `setbr` or `get_local_bridge.sh` scripts.

#### Bridge GUI
Once the `set_host_entries.sh` script has been run, you will need to browse to `https://bridge-ssl-proxy` and accept the certificate warning. Once that has been accepted you can then browse to `https://bridge-gui-ssl-proxy` and log in with the test user information that was given to you when running `sdk -i` to init your cluster.


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

## Developing

### Developing Against Local Node Module Dependencies
  To develop one of the Storj core apps against an unpublished local node_module, you add a git submodule to the .../vendor directory.
  The app when started does the following...
  + Runs a shell script that iterates through each of the directories in that folder
  + rm -rf's that node module from the apps node_modules folder inside of the container
  + copies the new module from the vendor folder into the node_modules directory
  + Repeats this for each module in the vendors folder until done
  + runs npm rebuild

## Contributing
If you would like to help make Storj better or would like to develop your application on top of the Storj platform, the Storj SDK aims to make this easy by tightening the feedback loop, removing as many requirements for getting started as possible, and allowing users to develop and test without accruing a balance while storing your test files.

### Pull Latest from Submodules
Update all modules
+ `./sdk -u [module]` - module defaults to all

or

Manually pull from tip of remote
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
+ `./sdk -b` (add -x for no-cache)

or

+ `docker-compose down`
+ `docker-compose rm -f` ?
+ `docker-compose build`
+ `docker-compose up -d`
+ `docker-compose logs -f`

### Rebuild Specific Service (container)
+ `./sdk -b [service]` (add -x for no-cache)

or

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

### Using the CLI against local setup
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

### Tasks
[x] 1) Get all services working each with one instance
[x] 1.1) Clean up the repo, make sure nothing unwanted is getting comitted and push
[x] 1.2) Confirm that the setup instructions work from a clean copy of master
[x]   + probably involve git pull --recurse-submodules
[x]   + for the first time you need to use --init
[x]   + git submodule update --init --recursive
[x] 2) Get local file upload/download working
[x] 3) Ensure that rebuilding specific containers is resiliant for each one (such that IP's etc... are updated on restart)
[x] 4) Work on docker-compose scale for farmers
[x]  + Add unique index for each farmer so scaling works
[ ] 5) Rename and update entry script to assist in the following
[x]   + Bringing the cluster up and down
[x]   + Rebuilding the entire cluster and restarting
[x]   + Run the preconfigured cli from within a docker container (link binary from host? Or launch a container?
[ ]  + Watch for changes and automatically (optionally) rebuild and restart anything that has changed
[x]  + Rebuilding a particular container and restarting that service
[x]  + Viewing logs for all or each service
[ ]  + List addresses and ports of all services along with service type
[ ]6) Convert mongodb container to sharded replicaset with authentication enabled
[ ]  + This makes testing more like production
[ ]7) Tests
[ ]  + Test user creation
[ ]  + Test user activation
[ ]  + Test file upload
[ ]  + Test file download
[ ]8) Take Snapshots of Cluster State
[ ]  + Get the state of the cluster the way that you want it
[ ]  + Copy the mongodb data somewhere
[ ]  + Copy the farmer keys and data somewhere, etc...
[x]9) Cleanup / Reset
[x]  + Reset the state of the DB
[x]  + Reset the state of the Farmer

## Known Issues

### Corrupt .storjcli config file
  When accessing environments locally that change in state frequenty but may use the same IP's, there is a chance that your local config files generated by the cli may get corrupted. This can be resolved by deleting the appropriate `~/.storjcli/id_ecdsa_(...` file but do this at your own risk as you need to make sure that you arent' removing any important keys for your real Storj account.

### Renter Whitelist
  When renter comes up it should expose its renter ID to the farmers somehow so that when they come up they can be put on the whitelist for every farmer or we sould find how to disable the requirement of the whitelist

#### Container host DNS resolution
  We currently configure a few entries in your /etc/hosts file for the bridge and bridge-gui but it does not manage all hostnames. It likely could but needs have some thought put into it before we move forward.

  + Something like this? https://github.com/bnfinet/docker-dns
