'use strict';
var httpUtil = require('../util/http/http');
var functionsIndex = require('../util/functions/functionsIndex');


/**
 * getAnalysisFunctions
 *
 * returns List
 **/
exports.getAnalysisFunctions = function(args, res, next) {
  var result = null;
  try{
    result = functionsIndex.getFunctionDefs();
    httpUtil.endHttpOK(result, res);
  }catch(error){
    httpUtil.endHttpErr(error, res);
  }
}


/**
 * returns a list of supported parameter types
 *
 * returns List
 **/
exports.getParameterTypes = function(args, res, next) {
  var result = null;
  try{
    result = functionsIndex.getParameterTypeDefs();
    httpUtil.endHttpOK(result, res);
  }catch(error){
    httpUtil.endHttpErr(error, res);
  }
}

