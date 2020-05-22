'use strict'

module.exports = {

    createError: (code, message) => {
        var result = new Error(message);
        result.statusCode = code;
        result.stack = null;
        return result;  
    },

    create403Error: (message) =>{
        var result = new Error("operation is not authorised: " + message);
        result.statusCode = 403;
        result.stack = null;
        return result;
    },
    create500Error: (message) => {
        var result = new Error(message);
        result.statusCode = 500;
        result.stack = null;
        return result;
    },
    create400Error:(message) => {
        var result = new Error("Bad Request: " + message);
        result.statusCode = 400;
        result.stack = null;
        return result;
    },
    create401Error:(message) => {
        var result = new Error("Authorization failed: " + message);
        result.statusCode = 401;
        result.stack = null;
        return result;
    },
    createNotYetImplemented: (message) => {
        var result = new Error("Not yet implemented: " + message);
        result.statusCode = 500;
        result.stack = null;
        return result;
    },
    stringifyError: (err) => {
        var plainObject = {};
        Object.getOwnPropertyNames(err).forEach(function(key) {
          plainObject[key] = err[key];
        });
        return JSON.stringify(plainObject, null, '\t');
    }


}