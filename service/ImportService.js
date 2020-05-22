'use strict';
var httpUtil = require('../util/http/http');
var exportUtil = require('../util/export/export');

exports.postImport = function(args, res, next) {
  /**
   * parameters expected in the args:
  * secret (String)
  * snapshotZip (file)
  **/
  let snapshotZip = {
    data: null,
    mimetype: null,
    filename: null,
    encoding: null
  }
  let snapshotSecret = null;

  try{
    snapshotZip.data = args.snapshotZip.value.buffer || null;
    snapshotZip.mimetype = args.snapshotZip.value.mimetype || null;
    snapshotZip.filename = args.snapshotZip.value.originalname || null;
    snapshotZip.encoding = args.snapshotZip.value.encoding || null;

    snapshotSecret = args.secret.value; //needs changing: tit exposes a secret 

    let result = exportUtil.postImport(snapshotZip, snapshotSecret);
    httpUtil.endHttpOK(result, res);
  } catch (error) {
    httpUtil.endHttpErr(error, res);
  }
}
