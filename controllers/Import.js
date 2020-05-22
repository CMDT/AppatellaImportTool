'use strict';


var ImportService = require('../service/ImportService');

module.exports.postImport = function postImport (req, res, next) {
  ImportService.postImport(req.swagger.params, res, next);
};
