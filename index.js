'use strict';

var filesystem = require('./util/system/filesystem');
var fs = require('fs-extra');

var initialise = function () {


  var app = require('connect')();
  var http = require('http');
  var swaggerTools = require('swagger-tools');
  var jsyaml = require('js-yaml');



  // swaggerRouter configuration
  var options = {
    controllers: './controllers',
  };

  // The Swagger HTTP REST interface document (require it, build it programmatically, fetch it from a URL, ...)
  var spec = fs.readFileSync('./api/swagger.yaml', 'utf8');
  var swaggerDoc = jsyaml.safeLoad(spec);

  var port = swaggerDoc.host.split(':')[1];  //WILL THROW IF PORT NOT DEFINED IN DOC

  filesystem.initialise();
 

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
    var server = http.createServer(app).listen(port, function () {
      console.log('SERVER: localhost, port %d ', port);
    });
  });
}




// this is for unhandled async rejections. See https://blog.risingstack.com/mastering-async-await-in-nodejs/
process.on('unhandledRejection', (err) => {
  console.error(err);
  process.exit(1);
});


initialise();
