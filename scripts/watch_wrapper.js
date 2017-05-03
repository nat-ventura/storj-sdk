#!/bin/env node

var spawn = require('child_process').spawn;

function start() {
  console.log('Starting watchers...');

  // Could require nodemon here and use that instead of spawn
  // Also can remove watch.sh from the pipeline and call watcher.js directly from here
  // Can turn the watched files into reusable variables
  var watchBridgeGui = spawn('./scripts/watch.sh', ['bridge-gui', 'bridge-gui']);
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
}

start();
