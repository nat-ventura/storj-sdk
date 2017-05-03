#!/bin/env node

// This requires nodemon to be installed globally currently
//
// In the future, we will build this to run in a container and have control over
// docker-compose from within the container
var nodemon = require('nodemon');
var spawn = require('child_process').spawn;

var watcherPath = './scripts/watcher.js';
var watchServices = [
  {
    'name': 'bridge-gui',
    'watchPaths': [
      './bridge-gui/bridge-gui/',
      './bridge-gui/bridge-gui/Dockerfile'
    ],
    'watchExtensions': 'js dockerfile',
    'serviceRoot': 'bridge-gui'
  },
  {
    'name': 'bridge-gui-vue',
    'watchPaths': [
      './bridge-gui/bridge-gui-vue/',
      './bridge-gui/bridge-gui-vue/Dockerfile'
    ],
    'watchExtensions': 'js dockerfile',
    'serviceRoot': 'bridge-gui-vue'
  },
  {
    'name': 'bridge',
    'watchPaths': [
      './bridge/bridge/'
    ],
    'watchExtensions': 'js dockerfile',
    'serviceRoot': 'bridge'
  }
]

function start() {
  console.log('Starting watchers...');

  /*
  watchServices.forEach(function(service) {
    console.log(`Starting watch on service ${service.name}`);

    var script = watcherPath + " " + service.name;

    nodemon({
      script: "./scripts/watcher.js " + service.name + " " + service.serviceRoot
    });

    nodemon.on('start', function() {
      console.log(`Watcher for ${service.name} started.`);
    });

    nodemon.on('crash', function() {
      console.log(`Watcher for ${service.name} has crashed.`);
    });
  });
  */


  watchServices.forEach(function(service) {
  // Could require nodemon here and use that instead of spawn
  // Also can remove watch.sh from the pipeline and call watcher.js directly from here
  // Can turn the watched files into reusable variables
    var watchBridgeGui = spawn('./scripts/watch.sh',
      ['bridge-gui', 'bridge-gui']
    );
    var watchBridgeGuiVue = spawn('./scripts/watch.sh', ['bridge-gui-vue', 'bridge-gui']);
    var watchBridge = spawn('./scripts/watch.sh', ['bridge', 'bridge']);

    watchBridgeGui.stdout.on('data', function(data) {
      console.log('[info] [bridge-gui] ' + data.toString());
    });

    watchBridgeGui.stderr.on('data', function(data) {
      console.log('[error] [bridge-gui] ' + data.toString());
    });

    watchBridgeGui.on('exit', function(exitCode) {
      console.log('[exit] [bridge-gui] Watcher exiting with code: ' + exitCode);
    });

    watchBridgeGuiVue.stdout.on('data', function(data) {
      console.log('[info] [bridge-gui-vue] ' + data.toString());
    });

    watchBridgeGuiVue.stderr.on('data', function(data) {
      console.log('[error] [bridge-gui-vue] ' + data.toString());
    });

    watchBridgeGuiVue.on('exit', function(exitCode) {
      console.log('[exit] [bridge-gui-vue] Watcher exiting with code: ' + exitCode);
    });

    watchBridge.stdout.on('data', function(data) {
      console.log('[info] [bridge] ' + data.toString());
    });

    watchBridge.stderr.on('data', function(data) {
      console.log('[error] [bridge] ' + data.toString());
    });
    watchBridge.on('exit', function(exitCode) {
      console.log('[exit] [bridge] Watcher exiting with code: ' + exitCode);
    });
  });
}

start();
