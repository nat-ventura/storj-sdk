#!/bin/env node

// On first start set variable to start state
var initialStart = true;
var intId;

function live() {
  intId = setInterval(function() {
    console.log('Living...');
  }, 1000);
}

// Loop forever and catch events until we're restarted
function start() {
  process.on('SIGINT', function() {
    console.log("Got SIGINT. Exiting.");

    process.exit(0);
  });

  process.on('SIGUSR2', function() {
    console.log("Got restart request from Nodemon");
    clearInterval(intId);

    process.exit(0);
  });

  if (initialStart === true) {
    // Kick off rebuild of the service here
    console.log("Would kick off rebuild of the service now...");
    initialStart = false;
  }

  live();
}

start();
