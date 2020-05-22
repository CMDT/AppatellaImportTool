'use strict';
var CONSUMER_API_ADDRESS = null;
var CONSUMER_API_PORT = null;
var CONSUMER_API_SCHEME = null;

/**
 * - consumerAPIScheme
 * either http or https, depending on server deployment - either local or remote
 * consumerAPIScheme is placed into the swagger YAML file, so that the swagger SPWA behaves itsself, however it is deployed.
 * 
 * - consumerAPIAddress
 * slotted into the YAML file which is downloaded by the so swagger SPWA. This means that we can deploy from the same source code to different locations
 * automatically
 * 
 * - consumerAPIPort 
 * when running remotely, this is always 443
 * when running locally, it can be overridden by environment variables, so that multiple servers can run on the same machine.
 * 
 * @param {*} externalIdSystem 
 */
var initialise = (consumerApiScheme, consumerApiAddress, consumerApiPort) => {
  CONSUMER_API_SCHEME = consumerApiScheme;
  CONSUMER_API_ADDRESS = consumerApiAddress;
  CONSUMER_API_PORT = consumerApiPort;
}


var createConsumerApiAddress = () => {
  
    // Local ip address that we're trying to calculate
  var  address = null;
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

  if(!address){
    throw new Error("unable to generate consumer API address.");
  }
  
  return address;

}


var getConsumerApiAddress = () => {
  var result = null;
  if (!CONSUMER_API_ADDRESS) {
    CONSUMER_API_ADDRESS = createConsumerApiAddress();
  }
  result = CONSUMER_API_ADDRESS;
  return result;
}

var getConsumerApiScheme = () => {
    return CONSUMER_API_SCHEME;
}


var getConsumerApiPort = () => {
  return CONSUMER_API_PORT;
}

var createScopeInfo = (externalId, scopes) => {
  return {
    externalId: externalId,
    scopes: scopes
  }
};

module.exports = {
  initialise: initialise,
  createScopeInfo: createScopeInfo,
  getConsumerApiScheme : getConsumerApiScheme,
  getConsumerApiAddress : getConsumerApiAddress,
  getConsumerApiPort: getConsumerApiPort
};

