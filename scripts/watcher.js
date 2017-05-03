#!/bin/env node

console.log('starting watcher');

var exec = require('child_process').exec;

// On first start set variable to start state
var initialStart = true;
var intId;

var serviceName = process.argv[2];

function live() {
  intId = setInterval(function() {
    //console.log('Living...');
  }, 1000);
}


function restartService(sn, callback) {
  console.log('Triggering rebuild on service ' + sn);

  exec("docker-compose up --build -d " + sn,
    function(err, stdout, stderr) {
      console.log('stdout: ' + stdout);
      console.log('stderr: ' + stderr);

      if (err !== null) {
        console.log('exec error: ' + err);
      }

      return callback(err, stdout);
    }
  );
}

// Loop forever and catch events until we're restarted
function start() {
  console.log('Service name is: ' + serviceName);

  process.on('SIGINT', function() {
    console.log("Got SIGINT. Exiting.");

    clearInterval(intId);

    process.exit(1);
  });

  process.on('SIGUSR2', function() {
    console.log("Got restart request from Nodemon");

    restartService(serviceName, function(err, output) {
      if (err) {
        console.log("Error rebuilding service: " + err);
      }

      console.log('Service rebuilt: ' + output);
    });
  });

  if (initialStart === true) {
    // Kick off rebuild of the service here
    console.log("Would do first run stuff now...");

    initialStart = false;
  }

  live();
}

start();
