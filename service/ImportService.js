'use strict';
var httpUtil = require('../util/http/http');
var importexport = require('../util/service/importexport');



/**
 * parameters:
 * source_path: string: the local path of the 7-zip encoded, AES256 encypted file to be imported
 * secret: string: the password used when exporting the file
 * destination_db: the name of the DB to be imported to.
 */
exports.postImport = function(args, res, next) {

  var source_path = args.source_path.value;
  var secret = args.secret.value;
  var destination_db = args.destination_db.value;

  
  importexport.postImport(source_path, secret, destination_db)
    .then((result) => {
      httpUtil.endHttpOK(result, res);
    })
    .catch((error) =>{
      httpUtil.endHttpErr(error, res);
    });
}
