'use strict';

var { Pool } = require('pg');
var pgtools = require('pgtools');
const copyTo = require('pg-copy-streams').to;
const copyFrom = require('pg-copy-streams').from;
const format = require('pg-format');
const fs = require('fs-extra');
var debug = require('debug');
var log = debug('app:log');
var error = require('../error/error');

var THE_POOL = null;
var THE_CONFIG = null;


/**
 * initialises the database and connection pool.
 * we assume that the dabase is on localhost
 * @param {*} url 
 */
async function initialise(name) {
  // see : https://node-postgres.com/features/connecting

  // remove all connections to the DB
  if (THE_POOL) {
    await THE_POOL.end();
  }

  THE_CONFIG = {
    host: 'localhost',
    database: name,
    ssl: false
  };
  
  try{
    await pgtools.dropdb(THE_CONFIG, THE_CONFIG.database);
  }catch(err){
    throw (new Error("Error removing the old database: \n" + err.message));
  }

  try{
    await pgtools.createdb(THE_CONFIG, THE_CONFIG.database);
  }catch(err){
    throw (new Error("Error creating the new database: \n" + err.message));
  }

  THE_POOL = new Pool(THE_CONFIG);
 
};







var createColumnSpec = function (header, type) {
  return {
    header: header,
    type: type,
    spec: header + " " + type
  }

}

var createTextColumnSpecs = function (columnNames) {
  var result = [];
  if (columnNames) {
    for (var index = 0; index < columnNames.length; index++) {
      var columnSpec = createColumnSpec(columnNames[index], 'TEXT');
      result.push(columnSpec);
    }
  }
  return result;
}


var createTableSpec = function (name, columnSpecs) {
  var headers = [];
  var specs = [];
  if (!columnSpecs) {
    columnSpecs = [];
  }

  for (var i = 0; i < columnSpecs.length; i++) {
    headers.push(columnSpecs[i].header);
    specs.push(columnSpecs[i].spec);
  }

  return {
    name: name,
    specs: specs,
    headers: headers
  }
}


var query = async function (text, params) {
  var result = null;
  const client = await THE_POOL.connect();
  try {
    result = client.query(text, params);
  } catch (e) {
    throw (new Error("SQL error : " + e.message));
  } finally {
    client.release();
  }
  return result;

};


var multiQuery = async function (queries) {

  var results = [];
  const client = await THE_POOL.connect();
  try {
    await client.query('BEGIN');
    for (var index = 0; index < queries.length; index++) {
      var query = queries[index];
      var text = query.text;
      var values = query.values;
      results.push(await client.query(text, values));
    }
    await client.query('COMMIT');
  } catch (e) {
    await client.query('ROLLBACK');

    throw (new Error("SQL Error: " + e.message));
  } finally {
    client.release();
  }
  return results;

}




var createTabularQuery = (query) => {
  return {
    query: query,
    header: [],
    rows: []
  }
};


var createTableHeader = (jsonRow) => {
  var result = Object.keys(jsonRow);
  return result;
}

var createRow = (header, jsonRow) => {
  var result = null;

  var row = [];
  for (var index = 0; index < header.length; index++) {
    var colName = header[index];
    var value = jsonRow[colName];
    row.push(value);
  }

  result = row;

  return result;
}


var createRows = (header, jsonRows) => {
  var result = null;
  var rows = [];

  for (var index = 0; index < jsonRows.length; index++) {
    rows.push(createRow(header, jsonRows[index]));
  }
  result = rows;

  return result;
}

var populateAsTable = (tabularOutput, jsonRows) => {

  var header = [];
  var rows = [];
  if (jsonRows && jsonRows.length > 0) {
    header = createTableHeader(jsonRows[0]);
    rows = createRows(header, jsonRows);
  }
  tabularOutput.header = header;
  tabularOutput.rows = rows;
  delete tabularOutput.query;

}


var multiTabularQuery = async (
  tabularQueries
) => {

  var results = null;
  const client = await THE_POOL.connect();
  try {
    await client.query('BEGIN');
    for (var index = 0; index < tabularQueries.length; index++) {
      var tabularQuery = tabularQueries[index];
      var query = tabularQuery.query;
      var text = query.text;
      var values = query.values;
      var response = await client.query(text, values);
      var rows = null;
      if (response.rows) {
        if (response.rows.length > 0) {
          rows = response.rows;
        }
      }

      populateAsTable(tabularQuery, rows);

    }
    await client.query('COMMIT');
    results = tabularQueries;
  } catch (e) {
    await client.query('ROLLBACK');

    throw (new Error("SQL error: " + e.message));
  } finally {
    client.release();
  }
  return results;

}

function createRowFromArray(arrayNames, colDelimiter) {
  var result = "";

  if (arrayNames) {
    for (var index = 0; index < arrayNames.length; index++) {
      result += arrayNames[index];
      if (index < arrayNames.length - 1) {
        result += colDelimiter;
      }
    }
  }
  return result;

}


function createRowFromColumns(arrayColumns, rowIndex, colDelimiter) {
  var result = "";
  for (var index = 0; index < arrayColumns.length; index++) {
    if (rowIndex < arrayColumns[index].length) {
      result += arrayColumns[index][rowIndex];
      if (index < arrayColumns.length - 1) {
        result += colDelimiter;
      }
    } else {
      throw (new Error("there was a problem creating a row: the row index exceeded the length of the columns."));
    }
  }
  return result;
}

function createDelimitedTableContent(arrayHeaders, arrayColumns, colDelimiter, lineDelimiter) {
  var result = "";

  if (arrayColumns && arrayColumns.length > 0) {

    var headers = "";

    // headers
    if (arrayHeaders && arrayHeaders.length > 0) {
      if (arrayHeaders.length != arrayColumns.length) {
        throw (new Error("there was a problem creating the courses data file: the header columns were a different size to the data columns."));
      }
      headers = createRowFromArray(arrayHeaders, 0, colDelimiter);
      headers += lineDelimiter;
    }

    // data
    var colLength = arrayColumns[0].length;
    for (var index = 0; index < arrayColumns.length; index++) {
      if (arrayColumns[index].length != colLength) {
        throw (new Error("there was a problem creating the courses data file: the data columns were of different lengths. It's not possible to create rows."));
      }
    }

    var data = "";
    for (var index = 0; index < colLength; index++) {
      data += createRowFromColumns(arrayColumns, index, colDelimiter);
      data += lineDelimiter;
    }

    result = headers + data;

  }

  return result;

}


async function beginTransaction(client) {
  await client.query("BEGIN");
}

async function commitTransaction(client) {
  await client.query("COMMIT");
}


async function dropTempTable(client, tableName) {
  var query = "drop table " + tableName + ";";

  await client.query(query);
}

async function prepareTempTable(client, tableName, tableColumnSpecs) {
  //var query = "create table " + tableName + "( " + createRowFromArray(tableColumnSpecs, ',') + " );";
  //var query = "create temp table " + tableName + "( " + createRowFromArray(tableColumnSpecs, ',') + " );";
  var query = "create temp table " + tableName + "( " + createRowFromArray(tableColumnSpecs, ',') + " ) ON COMMIT DROP;";
  //var query = "create table " + tableName + "( " + createRowFromArray(tableColumnNames) + " text )";
  await client.query(query);
}

async function copyCSVToTable(client, tableName, tableColumnNames, csvReadStream) {
  await new Promise(function (resolve, reject) { //push file to table


    let done = function () {
      resolve();
    }

    let err = function (err) {
      reject(err);
    }

    var query = 'COPY ' + tableName + ' (' + createRowFromArray(tableColumnNames, ',') + ' ) FROM STDIN CSV HEADER';

    var stream = client.query(copyFrom(query));
    stream.on('error', err);
    stream.on('end', done);
    csvReadStream.pipe(stream);
  });

}

async function copyFilesToTables(directory) {

  let files = fs.readdirSync(directory)

  for (let file of files) {
    console.log("FILE TO DB: Writing ", file, " to Database");
    var tableName = file.split(".")[0];
    if (file.split(".")[1] != "sql") {
      await new Promise(function (resolve, reject) { //push file to table
        THE_POOL.connect().then(client => {

          let done = function () {
            console.log("FILE TO DB: ", file, " Written.");
            client.release();
            resolve();
          }

          let err = function (err) {
            console.log(err);
            //reject(err);
            resolve();
          }
          client.query("set session_replication_role = 'replica';")
          var stream = client.query(copyFrom('COPY ' + tableName + ' FROM STDIN CSV HEADER'));
          var fileStream = fs.createReadStream(directory + "/" + file);
          stream.on('error', err);
          stream.on('end', done);
          fileStream.pipe(stream);
        });
      })
    }
  }
}





// takes a  query, sanitises it and runs within the COPY TO process
// (which doesn't support parameterised queries.)
// query must be supported by pg-format,  which is the next best option to parameterise queries.
// output is piped to the specified file stream.
async function runQueryToFile(client, preparedQuery, writeStream) {
  return new Promise(function (resolve, reject) {

    var combinedQuery = format.withArray(preparedQuery.text, query.values);
    var stream = client.query(copyTo('COPY (' + combinedQuery + ') TO STDOUT CSV HEADER'));
    stream.pipe(writeStream);
    stream.on('error', reject);
    writeStream.on('finish', function () {
      console.log("finished stream");
      resolve();
    });

  });
}

async function singleQueryToFile(
  query,
  filePath) {
  let fileStream = fs.createWriteStream(filePath);
  var client = await THE_POOL.connect();

  try {
    await runQueryToFile(client, query, fileStream);
    console.log("runQueryToFile - completed.");
  } catch (e) {
    console.log("error: query: " + e.message);
  } finally {
    client.release();
    fileStream.close();
  }
}




async function tableQueriesToFiles(
  client,
  tableQueries,
  dirPath,
  extension,
  fnProgress
) {

  for (var index = 0; index < tableQueries.length; index++) {
    var tableQuery = tableQueries[index];
    var name = tableQuery.name;
    var query = tableQuery.query;
    console.log("query: " + name);
    let fileStream = fs.createWriteStream(dirPath + "/" + name + extension);

    if (fnProgress) {
      await fnProgress(index, tableQueries.length, name);
    }
    try {
      console.log("calling: runQueryToFile");
      await runQueryToFile(client, query, fileStream);
      console.log("returned: runQueryToFile");
    } catch (e) {
      console.log("error: query: " + e.message);
      throw (e);
    } finally {
      fileStream.close();
      console.log("closed stream");
    }


  }

}




async function createTempTable(client, tableSpec, tableDataFilepath) {

  let courseSelectionFileStream = null;
  if (fs.existsSync(tableDataFilepath)) {
    courseSelectionFileStream = fs.createReadStream(tableDataFilepath);
  }

  await prepareTempTable(client, tableSpec.name, tableSpec.specs);

  if (courseSelectionFileStream) {
    await copyCSVToTable(client, tableSpec.name, tableSpec.headers, courseSelectionFileStream);
    courseSelectionFileStream.close();
  }
  else {
    throw (new Error("no course ids were found for export."));
  }
}


// tempTableSpec, tempTableDataPath are optional
async function exportQueriesToFiles(preparedQueries, tempTableSpec, tempTableDataPath, outputPath, outputFileExtension, fnProgress) {

  var client = await THE_POOL.connect();
  try {
    await beginTransaction(client); // need to create a tempoarary table which gets dropped automatically at the end of the transaction
    if (tempTableSpec) {
      await createTempTable(client, tempTableSpec, tempTableDataPath);
    }
    await tableQueriesToFiles(
      client,
      preparedQueries,
      outputPath,
      outputFileExtension,
      fnProgress
    );

    //await dropTempTable(client, tempTableSpec.name);

    await commitTransaction(client);

  } finally {
    client.release();
  }
}


module.exports = {
  initialise: initialise,
  createTableSpec: createTableSpec,
  createTextColumnSpecs: createTextColumnSpecs,
  createColumnSpec: createColumnSpec,
  query: query,
  multiQuery: multiQuery,
  createTabularQuery: createTabularQuery,
  multiTabularQuery: multiTabularQuery,
  copyFilesToTables: copyFilesToTables,
  singleQueryToFile: singleQueryToFile,
  exportQueriesToFiles: exportQueriesToFiles,
  createDelimitedTableContent: createDelimitedTableContent

};