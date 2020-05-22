'use strict';
var httpUtil = require('../util/http/http');
var exportUtil = require('../util/export/export');


exports.deleteExport = function(args, res, next) {
  /**
   * parameters expected in the args:
  * fileId (String)
  * exportRequestId (String)
  **/
  // no response value expected for this operation
  let fileId = args.fileId.value;
  let exportRequestId = args.exportRequestId.value;
  
  exportUtil.deleteExport(fileId, exportRequestId)
  .then((result)=>{
    httpUtil.endHttpOK(result, res);
  })
  .catch((error)=>{
    httpUtil.endHttpErr(error, res);
  });
}

exports.getExport = function(args, res, next) {
  /**
   * parameters expected in the args:
  * filedId (String)
  **/
  // no response value expected for this operation
  let fileId = args.fileId.value;

  exportUtil.getExport(fileId, res)
  .then((result)=>{
    //httpUtil.endHttpOK(result, res);
    //result.end();
  })
  .catch((error)=>{
    httpUtil.endHttpErr(error, res);
  });
}

exports.getExportProgress = function(args, res, next) {
  /**
   * parameters expected in the args:
  * exportRequestId (String)
  **/
  
  /**
   * User wants to check progress of the export / get the fileId of the export.
   */
  let exportRequestId = args.exportRequestId.value;
  
  exportUtil.getExportProgress(exportRequestId)
  .then((result) => {
    httpUtil.endHttpOK(result, res);
  })
  .catch((error) =>{
    httpUtil.endHttpErr(error, res);
  });
}

exports.getRequestExport = function(args, res, next) {
  /**
   * parameters expected in the args:
  * exportRequestId (String)
  **/
  
  /**
   * So, The user has reserved an export and now they want to kick off the export process.
   * find uuid. find folder of that uuid. get secret. kick off export with specified secret and uuid.
   * save exported files to the uuid directory, then zip with secret.
  */
  let exportRequestId = args.exportRequestId.value;

  exportUtil.requestExport(exportRequestId)
  .then((result) => {
    httpUtil.endHttpOK(result, res);
  })
  .catch((error) =>{
    httpUtil.endHttpErr(error, res);
  });
}

exports.postReserveExport = function(args, res, next) {
  /**
   * parameters expected in the args:
  * secret (String)
  **/
  let result = null;

  let secret = args.body.value.secret;
  let anonymise = args.body.value.anonymise;
  let analysis = args.body.value.analysis;


  try {
    result = exportUtil.reserveExport(secret, anonymise, analysis);
    httpUtil.endHttpOK(result, res);
  } catch (error) {
    httpUtil.endHttpErr(error, res);
  }
}



