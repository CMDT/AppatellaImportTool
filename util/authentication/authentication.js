'use strict';

var debug = require('debug');
var log = debug('app:log');

var libjwt = require('jsonwebtoken');
var libjwks = require('jwks-rsa');
var authParser = require('auth-header');
var error = require('../error/error');


const supported_algorithms = {
    rsa: "RS256"
};

const supportedScopes = {
    researcher: "researcher" // can read all data, except user and organiations.
}

const researcherAuthorisedScopes = {
    researcher: "researcher"
}

const NOT_FOUND = -1;

var jwks_client = null;



var initialise = function (rsa_uri) {

    jwks_client = libjwks({
        cache: true,
        rateLimit: true,
        jwksRequestsPerMinute: 5, // Default value
        jwksUri: rsa_uri
    });


};


var get_access_token = function (req) {
    var authHeader = req.headers.authorization;
    var auth = authParser.parse(authHeader);
    var token = null;
    if (auth.scheme == "Bearer") {
        token = auth.token;
    }
    return token;
}


// attempt to verify the RSA signature of the access token, and then decode it.
var validate_RSA_access_token = function (token, kid, callback) {
    jwks_client.getSigningKey(kid, (err, key) => {
        if (!err) {
            const signingKey = key.publicKey || key.rsaPublicKey;
            libjwt.verify(
                token,
                signingKey,
                function(err, decoded){
                    callback(err, decoded);
                }
            );
        } else {
            callback(err,null);
        }
    });
}

var createOptions = function(externalId, scopes){
    return {
        externalId: externalId,
        scopes: scopes
    }
}

var createConsumerOptions = function (deploymentId, deploymentState, scopes, token){
    return {
        deploymentId: deploymentId,
        deploymentState: deploymentState,
        scopes: scopes,
        token: token
    }
}

var hasAuthorisedScope = function (scopeString, authorisedScopes) {
    var result = false;
    if (scopeString && scopeString.length > 0) {
        var scopes = Object.keys(authorisedScopes);

        for (var index = 0; index < scopes.length; index++) {
            var scope = scopes[index];
            if(scopeString.indexOf(scope) != NOT_FOUND){
                result = true;
                break;
            }
        }
    }
    return result;
}




/**
 * returns unauthenticated header information.
 * Use only if the request has been authenticated previously.
 */
var getHeaderInfo = function(req){

    var result = null;
    var access_token = get_access_token(req);
    // the access token is JWT - Base64 encoded, with signature
    if(access_token){
        var decoded_token = libjwt.decode(access_token, { complete: true });
        if (decoded_token) {
            result = createOptions(decoded_token.payload.sub, decoded_token.payload.scope);
        }
    }
    return result;

}

var appatella_researcher_auth = function (req, def, scopes, callback) {
    
    var err = null;

    // get the access token from the incoming request
    var access_token = get_access_token(req);

    if (access_token) {
        // the access token is JWT - Base64 encoded, with signature
        var decoded_token = libjwt.decode(access_token, { complete: true });

        if (decoded_token) {
            if (decoded_token.header.alg == supported_algorithms.rsa) {
                // the authorizing authority has defined the API as requiring RSA security

                // get the key id to pass to the RSA endpoint during validation
                var kid = decoded_token.header.kid;
                
                validate_RSA_access_token(
                    access_token,
                    kid,
                    function (err, valid_token) {
                        if (!err) {
                            if(hasAuthorisedScope(valid_token.scope, researcherAuthorisedScopes)){
                                callback(null, valid_token);
                            }else{
                                callback(error.create401Error("researcher scope is required for this service."));  
                            }
                        }else{
                            callback(error.create401Error(err.message));
                        }
                    });

            } else {
                callback(error.create401Error("unsupported JWT algorithm"));
            }
        } else {
            callback(error.create401Error("could not decode token"));
        }
    } else {
        callback(error.create401Error("token not found"));
    }
}







module.exports = {
    SUPPORTED_SCOPES: supportedScopes,
    initialise :initialise,
    createOptions: createOptions,
    getHeaderInfo: getHeaderInfo,
    appatella_researcher_auth: appatella_researcher_auth
};