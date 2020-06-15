'use strict';
var httpUtil = require('../util/http/http');
var importexport = require('../util/service/importexport');



/**
 * parameters:
 * source_path: string: the local path of the 7-zip encoded, AES256 encypted file to be imported
 * secret: string: the password used when exporting the file
 * destination_db: the name of the DB to be imported to.
 * destination_username: the username of the user granted access to the database
 * destination_password: the password for the user
 */
exports.postImport = function(args, res, next) {

  var source_path = args.source_path.value;
  var secret = args.secret.value;
  var destination_db = args.destination_db.value;
  var destination_username = args.destination_username.value;
  var destination_password = args.destination_password.value;

  
  importexport.postImport(  source_path, 
    secret, 
    destination_db,
    destination_username,
    destination_password)
    .then((result) => {
      httpUtil.endHttpOK(result, res);
    })
    .catch((error) =>{
      httpUtil.endHttpErr(error, res);
    });
}
