'use strict';


var ExportService = require('../service/ExportService');

module.exports.deleteExport = function deleteExport (req, res, next) {
  ExportService.deleteExport(req.swagger.params, res, next);
};

module.exports.getExport = function getExport (req, res, next) {
  ExportService.getExport(req.swagger.params, res, next);
};

module.exports.getExportProgress = function getExportProgress (req, res, next) {
  ExportService.getExportProgress(req.swagger.params, res, next);
};

module.exports.getRequestExport = function getRequestExport (req, res, next) {
  ExportService.getRequestExport(req.swagger.params, res, next);
};

module.exports.postReserveExport = function getReserveExport (req, res, next) {
  ExportService.postReserveExport(req.swagger.params, res, next);
};
