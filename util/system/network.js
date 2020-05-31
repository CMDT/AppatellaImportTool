'use strict';

var getIPAddress = () => {
  // Local ip address that we're trying to calculate
  var address = null;
  // Provides a few basic operating-system related utility functions (built-in)
  var os = require('os')
    // Network interfaces
    , ifaces = os.networkInterfaces();

  // Iterate over interfaces ...
  for (var dev in ifaces) {

    // ... and find the one that matches the criteria
    var iface = ifaces[dev].filter(function (details) {
      return details.family === 'IPv4' && details.internal === false;
    });

    if (iface.length > 0) address = iface[0].address;
  }

  if (!address) {
    throw new Error("unable to generate consumer API address.");
  }

  return address;

};

module.exports = {
  getIPAddress: getIPAddress
};