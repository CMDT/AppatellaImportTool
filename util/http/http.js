'use strict'

var errorApi = require('../error/error');

var endHttpOK = (result, response) => {
    var params = {};
    params['application/json'] = result;
    response.setHeader('Content-Type', 'application/json');
    response.end(JSON.stringify(params[Object.keys(params)[0]] || {}, null, 2));
} 


var endHttpErr = (error, response) => {
    response.statusCode = error.statusCode;
    var message = errorApi.stringifyError(error);
    response.end(message);
}

module.exports = {
    endHttpOK: endHttpOK,
    endHttpErr: endHttpErr
};