'use strict';

var DEFAULT_LOCAL_PORT = 8000;
var DEFAULT_REMOTE_PORT = 443;
var DEFAULT_LOCAL_SCHEME = 'http';
var DEFAULT_REMOTE_SCHEME = 'https';

var LOCALHOST = 'localhost';

var netutil = require('./util/system/network');
var filesystem = require('./util/system/filesystem');
var fs = require('fs-extra');






var getSwaggerUIConfig = function(){
  var result = {};

  // the port on which the server must listen
  result.existingPort = process.env.PORT;

  // scheme advertised by swagger doc as that over which to communicate with the API
  result.scheme = process.env.API_SCHEME;

  // domain advertised by swagger doc as that over which to communicate with the API
  result.domain = process.env.API_DOMAIN;

  // port advertised by swagger doc as that over which to communicate with the API
  // in the swagger doc, this value overrides the value set by PORT
  result.port = process.env.API_PORT;

  return result;
}




// Function which collates information and injects it to the swaggerdoc;
// the document which is read by clients of the interface.
//
// Information is read from the envornment variables:
//
// PORT: this is the actual port the system is listening on.
// For instance, heroku will define this as a read-only value.
// API_PORT: this is the port the YAML will advertise the interface on
// API_DOMAIN: this is the domain the YAML will advertise the interface on
// API_SCHEME: this is the scheme the YAML will advertise the interface on.
// If defined, these override the settings in the yaml
//
// Deployment:
// Heroku
// - assigns its own PORT value
// - developer must define these values for inclusion in the YAML
// -- API_DOMAIN,
// -- API_SCHEME
// -- API_PORT
// Other server
// - may assign the PORT value
// - developer must define these values for inclusion in the YAML
// -- API_DOMAIN,
// -- API_SCHEME
// -- API_PORT
// localhost
// - may assign the PORT value
// - system should automatically define API_DOMAIN with IP Address of server on network
// - API_SCHEME should be defined by developer, but defaults to http
// - API_PORT should be defined by developer, but defaults to 8000
//
// RULES for inclusion in YAML
// API_DOMAIN overrides YAML. If API_DOMAIN == 'localhost', we substitute IP address of server (so we can create QR codes which work)
// PORT overrides YAML. API_PORT overrides PORT (so we can mask heroku)
// if on heroku, PORT is ignored. Must use API_PORT
// if on other server can just define PORT
// if on localhost can just define PORT
// if on localhost, PORT, API_PORT default to DEFAULT_LOCAL_PORT
// API_SCHEME overrides YAML.
// if on localhost, API_SCHEME defaults to DEFAULT_LOCAL_SCHEME
//
// returns a result containing the swaggerDoc, and summary info

var resolveSwaggerDoc = function(swaggerDoc, swaggerUIConfig){

  var result = {
    swaggerDoc: null,
    summary: {
      listenPort: null,
      scheme: null,
      address: null,
      domain: null
    }
  }

  var doc = {};
  doc.scheme = swaggerDoc.schemes[0];  //WILL THROW IF SCHEMES NOT DEFINED IN DOC
  doc.domain = swaggerDoc.host.split(':')[0];  //WILL THROW IF HOST NOT DEFINED IN DOC
  doc.port = swaggerDoc.host.split(':')[1];  //WILL THROW IF PORT NOT DEFINED IN DOC


  var address = null;
  var domain = doc.domain;
  var isLocalHost = false;

  // RULES: domain overrides swagger doc
  console.log("swagger doc domain:")

  if(swaggerUIConfig.domain){
    console.log("overriding with: %s", swaggerUIConfig.domain);
    domain = swaggerUIConfig.domain;
  }else{
    console.log("WARNING: no domain override found. Swagger doc domain is unchanged.")
  }

  doc.domain = domain;

  if(doc.domain == LOCALHOST){
    isLocalHost = true;
    var ipAddress = netutil.getIPAddress();
    console.log("localhost resolves to: " + ipAddress);
    address = ipAddress;
  }else{
    address = doc.domain;
  }





  console.log("swagger doc port:");
  var port = null;
  var listenPort = swaggerUIConfig.existingPort; // ALWAYS the PORT env variable

  // RULES: existing port overrides YAML
  if(swaggerUIConfig.existingPort){
    port = swaggerUIConfig.existingPort;
    console.log("overriding swagger doc port with existing port: " + port);
  }
  //RULES: api_port overrides both
  if(swaggerUIConfig.port){
    port = swaggerUIConfig.port;
    console.log("overriding swagger doc port with port: " + port);
  }

  if(!port){
    if(isLocalHost){
      port = DEFAULT_LOCAL_PORT;
      console.log("overriding swagger doc with local port: " + port);
    }else{
      doc.port = DEFAULT_REMOTE_PORT;
      console.log("overriding swagger doc with remote port: " + port);
    }
  }

  if(!listenPort){ // was not defined in env variables
    listenPort = port;
  }

  doc.port = port;

  console.log("swagger doc scheme:");

  var scheme = null;

  if(swaggerUIConfig.scheme){
    scheme = swaggerUIConfig.scheme;
    console.log("overriding swagger doc with scheme: " + scheme);
  }

  if(!scheme){
    if(isLocalHost){
      scheme = DEFAULT_LOCAL_SCHEME;
      console.log("overriding swagger doc with default local scheme: " + scheme);
    }else{
      scheme = DEFAULT_REMOTE_SCHEME;
      console.log("overriding swagger doc with default remote scheme: " + scheme);
    }
  }

  doc.scheme = scheme;

  var hostAddrPort = doc.domain + ":" + doc.port;
  var schemes = [doc.scheme];

  swaggerDoc.host = hostAddrPort;
  swaggerDoc.schemes = schemes;

  result = {
    swaggerDoc: swaggerDoc,
    summary: {
      listenPort: listenPort,
      scheme: scheme,
      domain: domain,
      address: address,
      port: port
    }
  }

  return result;
}

var initialise = function () {


  var app = require('connect')();
  var http = require('http');
  var swaggerTools = require('swagger-tools');
  var jsyaml = require('js-yaml');
  var data = require('./util/data/data');

  // swaggerRouter configuration
  var options = {
    controllers: './controllers',
  };

  // The Swagger HTTP REST interface document (require it, build it programmatically, fetch it from a URL, ...)
  var spec = fs.readFileSync('./api/swagger.yaml', 'utf8');
  var swaggerDoc = jsyaml.safeLoad(spec);

  // fetch categorised system parameters from environment variables.
  var swaggerUIConfig = getSwaggerUIConfig();

  var swaggerDocResolve = resolveSwaggerDoc(swaggerDoc, swaggerUIConfig);

  swaggerDoc = swaggerDocResolve.swaggerDoc;
  var listenPort = swaggerDocResolve.summary.listenPort;

  filesystem.initialise();

  data.initialise(
    swaggerDocResolve.summary.scheme,
    swaggerDocResolve.summary.address,
    swaggerDocResolve.summary.port);


  // Initialize the Swagger middleware
  swaggerTools.initializeMiddleware(swaggerDoc, function (middleware) {
    // Interpret Swagger resources and attach metadata to request - must be first in swagger-tools middleware chain
    app.use(middleware.swaggerMetadata());

    // Validate Swagger requests
    app.use(middleware.swaggerValidator());

    // Route validated requests to appropriate controller
    app.use(middleware.swaggerRouter(options));

    // Serve the Swagger documents and Swagger UI
    app.use(middleware.swaggerUi(
      // use default Swagger Ui implementation
    ));

    // Start the server
    var server = http.createServer(app).listen(listenPort, function () {
      var address = data.getConsumerApiAddress();
      console.log('SERVER: listening on %s , port %d ', address, listenPort);
    });
  });
}






// this is for unhandled async rejections. See https://blog.risingstack.com/mastering-async-await-in-nodejs/
process.on('unhandledRejection', (err) => {
  console.log("GOT HERE !!!");
  console.error(err);
  // process.exit(1);
});


initialise();
