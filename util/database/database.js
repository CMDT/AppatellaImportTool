'use strict';


var service = require('./databaseservice');

module.exports = {
  initialise: service.initialise,
  copyFilesToTables: service.copyFilesToTables
}



