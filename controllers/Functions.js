'use strict';

var FunctionsService = require('../service/FunctionsService');

module.exports.getAnalysisFunctions = function deleteExport (req, res, next) {
  FunctionsService.getAnalysisFunctions(req.swagger.params, res, next);
};

module.exports.getParameterTypes = function getExport (req, res, next) {
  FunctionsService.getParameterTypes(req.swagger.params, res, next);
};
