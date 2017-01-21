# storj-sdk
The Storj Developer Kit

## Setup

## Usage
+ Setting project versions
+ Pulling current versions of projects in a particular environment (prod, staging)
+ Running certain services locally and pointing to others in other environments
+ Pulling production like data
+ Running load generation against your environment (local or remote)

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


