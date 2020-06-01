'use strict';

var functions = require('./functions');

const parameterTypeDefs = {
    string: {
        name: "string"
    },
    number: {
        name: "number"
    },
    boolean: {
        name: "boolean"
    },
    datetime: {
        name: "datetime"
    }
};

const functionDefLookup = {
    exportCourses: {
        name: "Export all authorised courses",
        description: "Exports courses which have been flagged by participants as shared.",
        parameters: {
            course_ids: {
                name: "Course Ids",
                isRequired: false,
                type: parameterTypeDefs.string.name,
                isArray: true,
                isBase64EncodedJSON: false
            }
        }
    },
    exportCourseSessionCompletion: {
        name: "Export course session completion",
        description: "Gets sorted session completion data for specified courses",
        parameters: {
            course_ids: {
                name: "Course Ids",
                isRequired: false,
                type: parameterTypeDefs.string.name,
                isArray: true,
                isBase64EncodedJSON: false
            }
        } 
    },
    exportCourseSessionAnswers: {
        name: "Export course session answers",
        description: "Gets sorted session answers for specified courses",
        parameters: {
            course_ids: {
                name: "Course Ids",
                isRequired: false,
                type: parameterTypeDefs.string.name,
                isArray: true,
                isBase64EncodedJSON: false
            }
        } 
    },
    exportCourseOutcomeAnswers: {
        name: "Export course outcome answers",
        description: "Gets sorted outcome answers for specified courses",
        parameters: {
            course_ids: {
                name: "Course Ids",
                isRequired: false,
                type: parameterTypeDefs.string.name,
                isArray: true,
                isBase64EncodedJSON: false
            }
        } 
    }

};



function objectToList(parent) {
    var propNames = Object.keys(parent);
    for (var index = 0; index < propNames.length; index++) {
        var propName = propNames[index];
        var prop = parent[propName];
        if (typeof (prop) == 'object') {
            parent[propName] = [];
            var list = parent[propName];
            objectInList(prop, list);
        }
    }
    return list;
}

function objectInList(obj, list) {
    var propNames = Object.keys(obj);
    for (var index = 0; index < propNames.length; index++) {
        var propName = propNames[index];
        var prop = obj[propName];
        if (typeof (prop) == 'object') {
            prop.id = propName;
            list.push(prop);
            objectToList(prop);
        }
    }
    return list;

}




function parseBase64EncodedJSON(value) { // will throw on parse error, as user will want to know.

    var buf = Buffer.from(value, 'base64');
    return JSON.parse(buf);

}

function parseArray(value, parseDefinition) { // assume comma delimited values
    var array = value.split(",");
    for (element in array) {
        if (parseDefinition.type) {
            var type = parseParameterType(parseDefinitionType);
            parseType(value, type);
        }
    }
}

function parseBool(value) {
    return Boolean(value);
}

function parseDateTime(value) {
    return Date(value);
}


function parseToType(value, type) {
    var result = value;
    if (type == parameterTypeDefs.boolean) {
        result = parseBool(value);
    } else if (type == parameterTypeDefs.datetime) {
        result = parseDateTime(value);
    } else if (type == parameterTypeDefs.number) {
        result = parseNumber(value);
    }
    return result;
}


function parseParameterType(type) {
    var result = parameterTypeDefs.string;

    var defs = Object.keys(parameterTypeDefs);

    for (var i = 0; i< defs.length; i++) {
        var def = defs[i];
        if(def && type){
            if (type.valueOf() == def.valueOf()) {
                result = parameterTypeDefs[def];
                break;
            }
        }
    }
    return result;
}


function parseArray(value, parseDefinition) { // assume comma delimited values
    var result = [];
    var array = value.split(",");
    for(var i=0; i<array.length; i++) {
        var item = array[i];
        result.push(parseSingle(item, parseDefinition));
    }
    return result;
}

function parseSingle(value, parseDefinition) {
    var result = value;
    if (parseDefinition.isBase64EncodedJSON) {
        result = parseBase64EncodedJSON(value);
    } else if (parseDefinition.type) {
        var type = parseParameterType(parseDefinition.type);
        result = parseToType(value, type);
    }


    return result;
}



function parseValue(value, parseDefinition) {
    var result = value;

    if (parseDefinition.isArray) {
        result = parseArray(value, parseDefinition);
    } else {
        result = parseSingle(value, parseDefinition);
    }
    return result;
}


function listToObject(list, obj, parseDefinitions) {
    for (var index = 0; index < list.length; index++) {
        var item = list[index];
        if (item.id) { // items in the list must have an 'id' property to be recognised.
            var propName = item.id;
            var value = item.value; // items in the list must have a 'value' property to be parsed
            var parseDef = parseDefinitions[propName];

            var parsed = parseValue(value, parseDef);
            obj[propName] = parsed;
        }
    }
    return obj;
}


/**
 * 
 */
function parseParameters(parameters, parameterDef) {
    return listToObject(parameters, {}, parameterDef);
}


/**
 * turns the function definitions from a lookup into a form which can be queries by the REST service interface, without changing the YAML, every time we add a new function.
 * output format is like this:
 * functionList : [
 *  {
 *   name: "name",
 *   description: "description",
 *   id: "id",
 *   parameters: [
 *     {
 *       "id": "id",
 *       "name": "name",
 *       "type": "type"
 *       "isArray": true,
 *       "isBase64EncodedJSON": "isBase64EncodedJSON",
 *     }
 * ]
 */
function getFunctionDefs() {
    return (objectInList(functionDefLookup, []));
}

function getParameterTypeDefs() {
    return Object.keys(parameterTypeDefs);
}

function seekFunction(candidateId) { // this function throws if id is in any way invalid, or does not match a registered function
    var result = functionDefLookup[candidateId];

    if (!result) {
        throw (new Error("no function: " + candidateId));
    }
    return result;
}

async function runFunction( // throws
    workingFilePath,
    outputFilePath,
    analysisDef,
    afnSendMessage) {

    var functionId = analysisDef.functionId; // must exist
    var parameters = analysisDef.parameters; //optional 

    if (!functionId) {
        throw (new Error("no analysis function was defined."));
    }

    if (!functionDefLookup[functionId]) {
        throw (new Error("no analysis function was found for id: " + functionId));
    }

    var analysisFunction = functions[functionId];
    var parameterDef = functionDefLookup[functionId].parameters;

    var parameters = null;
    if (analysisDef.parameters) {
        parameters = parseParameters(analysisDef.parameters, parameterDef);
    }

    await analysisFunction(parameters, workingFilePath, outputFilePath, afnSendMessage);

}


module.exports = {
    seekFunction: seekFunction,
    runFunction: runFunction,
    getFunctionDefs: getFunctionDefs,
    getParameterTypeDefs: getParameterTypeDefs
}