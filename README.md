Storj Developer Kit
===================

The Storj Developer Kit is designed to enable both Team Members at Storj Labs and Community Members alike to quickly set up a fully working, complete and consistent environment with which to develop, test and experiment.

## Setup

### Dependencies

#### Required
+ jq ( `apt-get install jq` or `brew install jq` )
+ expect ( `apt-get install expect` or `brew install expect` )

#### Optional
+ A VPN client (see below under Access Cluster) - Required for OSX and other systems that run the docker engine inside of a VM
+ Ruby ( this is temporary ) - Required to use the ./sdk script
+ NodeJS v6.9.5 or Greater - Required to run the storj cli locally

### SDK Script (./sdk)
The `sdk` script wraps most of the functionality that you will need when using docker, docker-compose and vpn for these services.

#### Super Quick Start
+ `git clone https://github.com/Storj/storj-sdk.git --recursive`
+ `./sdk -i`
+ `. scripts/setbr`

Done.

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

### 3) Access Cluster (OSX Only)
To access your cluster (from OSX) you'll need to install an OpenVPN compatible VPN client.
If you want to use the VPN in Linux for any reason, you'll want to check the box telling your VPN client not to route all traffic through this VPN, only traffic destined for subnets that it controls.

+ [Tunnelblick](https://tunnelblick.net/downloads.html)
+ [Viscosity](https://www.sparklabs.com/viscosity/download/)

After you have installed and started your VPN client, browse from the root directory of the repository to the vpn folder and run (or import) the VPN config that was generated after you brought the cluster up. It should be named `storj-local.ovpn`.

#### Storj CLI
To use the CLI, you'll need to set the `STORJ_BRIDGE` environment variable to the address of your local bridge.

From the root of the sdk, run the following command:
`. scripts/setbr`

##### Behind the Scenes
To use the local bridge you'll need to either export the `STORJ_BRIDGE` environment variable or preface your storj command with STORJ_BRIDGE=[local_bridge] replacing [local_bridge] with the bridge address.

A script is provided to programatically determine the URL of your local bridge and can be found here:
`./scripts/get_local_bridge.sh`.

You can go ahead and export the bridge variable in one go like so:

`eval export STORJ_BRIDGE=$(./scripts/get_local_bridge.sh)`.
This is what the `setbr` script from above does.

#### Local SSL
To access services locally over SSL, you will need to set hostnames for them in your local hosets file. The process has been scripted which can be run from the root of the storj-sdk as follows:

`./scripts/set_host_entries.sh`

Once the `set_host_entries.sh` script has been run, you will need to browse to `https://bridge-ssl-proxy` and accept the certificate warning. Once that has been accepted you can then browse to `https://bridge-gui-ssl-proxy` and log in with the test user information that was given to you when running `sdk -i` to init your cluster.

##### Behind the Scenes
To access the local bridge via ssl, you will need to have run the `set_host_entries.sh` script. You should then be able to use `https://bridge-ssl-proxy` in place of the address obtained by the `setbr` or `get_local_bridge.sh` scripts.

#### Bridge
[https://bridge-ssl-proxy](https://bridge-ssl-proxy)

#### Bridge GUI
[https://bridge-gui-ssl-proxy](https://bridge-gui-ssl-proxy)

##### Non SSL
[http://bridge](http://bridge)


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

You can use the `sdk` script to check and set versions (tag, sha, master, etc...) of the primary services and vendor services.

Set the version of bridge to tag v5.6.0
```
./sdk -v bridge@v5.6.0
```

Set the version fo bridge to tag v5.6.0 and share to v2.5.0
```
./sdk -v bridge@v5.6.0,share@v2.5.0
```

Set the version of the storj-lib vendored dependency to v6.3.1
* Note that for vendored dependencies, you must add the vendor/ prefix to the module name
```
./sdk -v vendor/storj-lib@v6.3.1
```

Set all to latest (coming soon)
```
./sdk -v latest
```

List current version or commit for all modules/services (coming soon)
```
./sdk -v
```

#### Manual management of Vendor Modules
Submodules are managed and retained by the `.gitmodules` file in the root of the SDK. Vendor modules ( i.e. `vendor/storj-lib` ) can exist here but not be checked out or used. If desired, you can pull in one of the predefined submodules or add additional modules. The following are the steps to manage this process manually.

Pull a submodule that exists in `.gitmodules` already
(first check the .gitmodules file to ensure that the module you are going to pull in exists)
```
git submodule update --init vendor/storj-lib
```

Add a submodule that has not been added to the `.gitmodules` file yet
```
git submodule add --name storj-lib https://github.com/storj/core vendor/storj-lib
cd vendor/storj-lib
git config remote.origin.pushurl git://github.com/storj/core
```
This will add the module such that anyone can pull from git but at the same time, anyone with push permissions will be able to do so.

Remove a submodule but leave it in `.gitmodules` so that you can pull it back in later
(first ensure that there are no uncomitted changes to the repository)
```
git submodule deinit vendor/storj-lib
rm -rf vendor/storj-lib
```


#### Thoughts on Dependencies
We're currently working through designing the way that managing the dependencies will work.

We could provide two levels of dependencies.

The first would be deps that Storj owns, the second could be deps that are completely external. We could provide un initialized got submodules for all of the Storj owned dependencies and the user would initiate commands to bring them in or deinit them when needed. These could be kept in line with the current stable service set in some automated way like git tags, etc...

The question is how should we manage these dependencies (in the form of submodules if we go that route).

For the modules not owned by Storj, we could provide the tools to obtain and manage them but any changes here would be in a .gitignore file such that those changes would not be comitted.

The reason behind using submodules instead of pointing to a users local copy of a repository or dependency is due to a limitation on docker which requires us to have any sources that we want pulled into a container, in the root level of that containers context. In our case, we're building with docker-compose and the root of the SDK is the root for docker-compose. Links dont' work here...

#### Behind the Scenes
  To develop one of the Storj core apps against an unpublished local node_module, you add a git submodule to the `$SDK_ROOT/vendor` directory.
  The app when started does the following...
  + Runs a shell script that iterates through each of the directories in that folder
  + rm -rf's that node module from the apps node_modules folder inside of the container
  + copies the new module from the vendor folder into the node_modules directory
  + Repeats this for each module in the vendors folder until done
  + runs npm rebuild

  This is currently only implemented for the following services
  + Storj Share

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

### Directory Structure
| Description                | SDK / Project                                                             | Container                               | Notes                 |
| -------------------------- | ------------------------------------------------------------------------- | --------------------------------------- | --------------------- |
| App Directory in Container |                                                                           | `/opt/[app_name]`                       |                       |
| Config(s)                  |                                                                           | `/etc/storj/[app_name].conf`            |                       |
| Convenience Directories    |                                                                           | `/opt/[app_name]` -> `/opt/app`         |                       |
| Vendor Modules             |                                                                           | `/opt/vendor/[module_name]`             |                       |
| Dockerfiles                | `[sdk_root]/[app_name]/[repo_name]/dockerfiles/[service_name].dockerfile` |                                         |                       |
| Helper Scripts             | `[sdk_root]/[app_name]/scripts`                                           | `/usr/local/bin`                        |                       |

#### Dockerfiles
If at all possible, we should only create one Dockerfile per project or service. Using a different Dockerfile between development and production should be avoided as this will create differences in the build that is used to test and the one that will be shipped to production.

### Startup Scripts
In order to include vendored modules, a wrapper startup script needs to be used. The Dockerfile in the project should contain the CMD to start the service. The docker-compose configuration file should override this to employ the wait script as well as execute the script to copy vendored modules.

### Template Parsing
Templates are parsed by a bash script that recursively replaces instances of environment variable name with that environment variable names contents. This allows for being able to inject variables at build time or (with the seame variables/system) find and replace them at container start time. Using these variables at container start time is required for being able to inject secrets via env variable.

### Build & Test
Adding a Jenkins file to the root level of the projects repository will allow for creation of a pipeline in the Storj automated build system.

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
- [x] 1) Get all services working each with one instance
- [x] 1.1) Clean up the repo, make sure nothing unwanted is getting comitted and push
- [x] 1.2) Confirm that the setup instructions work from a clean copy of master
- [x]   + probably involve git pull --recurse-submodules
- [x]   + for the first time you need to use --init
- [x]   + git submodule update --init --recursive
- [x] 2) Get local file upload/download working
- [x] 3) Ensure that rebuilding specific containers is resiliant for each one (such that IP's etc... are updated on restart)
- [x] 4) Work on docker-compose scale for farmers
- [x]  + Add unique index for each farmer so scaling works
- [ ] 5) Rename and update entry script to assist in the following
- [x]   + Bringing the cluster up and down
- [x]   + Rebuilding the entire cluster and restarting
- [x]   + Run the preconfigured cli from within a docker container (link binary from host? Or launch a container?
- [ ]  + Watch for changes and automatically (optionally) rebuild and restart anything that has changed
- [x]  + Rebuilding a particular container and restarting that service
- [x]  + Viewing logs for all or each service
- [ ]  + List addresses and ports of all services along with service type
- [ ]  + Echo all commands that the helper script is running to educate the user on what the script is doing
- [ ] 6) Convert mongodb container to sharded replicaset with authentication enabled
- [ ]  + This makes testing more like production
- [ ] 7) Tests
- [ ]  + Test user creation
- [ ]  + Test user activation
- [ ]  + Test file upload
- [ ]  + Test file download
- [ ] 8) Take Snapshots of Cluster State
- [ ]  + Get the state of the cluster the way that you want it
- [ ]  + Copy the mongodb data somewhere
- [ ]  + Copy the farmer keys and data somewhere, etc...
- [x] 9) Cleanup / Reset
- [x]  + Reset the state of the DB
- [x]  + Reset the state of the Farmer

## Known Issues

### Linux VPN Routes ALL traffic through VPN
  There have been some cases where running the VPN config on Linux has routed all internet traffic through the local VPN which is not desired. This can be remedied by changing the configuration in your VPN client but we aim to push this setting out in the config provided.

### Corrupt .storjcli config file
  When accessing environments locally that change in state frequenty but may use the same IP's, there is a chance that your local config files generated by the cli may get corrupted. This can be resolved by deleting the appropriate `~/.storjcli/id_ecdsa_(...` file but do this at your own risk as you need to make sure that you arent' removing any important keys for your real Storj account.

### Renter Whitelist
  When renter comes up it should expose its renter ID to the farmers somehow so that when they come up they can be put on the whitelist for every farmer or we sould find how to disable the requirement of the whitelist

#### Container host DNS resolution
  We currently configure a few entries in your /etc/hosts file for the bridge and bridge-gui but it does not manage all hostnames. It likely could but needs have some thought put into it before we move forward.

  + Something like this? https://github.com/bnfinet/docker-dns

### VPN in Linux
  + You must add a route `0.0.0.0` to the VPN config when importing it on some Linux systems
  + You must configure the client to only route traffic destined for its network `Use this connection only for resources on its network`
