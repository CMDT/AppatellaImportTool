'use strict';


const uuidv4 = require('uuid/v4');
const errorApi = require('../error/error');
const dbApi = require('../database/database');
const filestructure = require('../system/filesystem');
const fs = require('fs-extra');
const node7z = require('node-7z');
const sevenBin = require('7zip-bin');

const fsdef = filestructure.definitions;
const schemaFilename = fsdef.schemaFilename;
const snapshotDirectory = fsdef.snapshotDirectory;
const importedDirectory = fsdef.importedDirectory; // directory in which to upload snapshot data


function unlockAndDecompress(sourcePath, secret, destinationPath) {

  return new Promise(function (resolve, reject) {

    const pathTo7zip = sevenBin.path7za
    const stream = node7z.extractFull(sourcePath, destinationPath, {
      $bin: pathTo7zip,
      password: secret,
      recursive: true
    });

    stream.on('data', function (data) {
      console.log(data.file);
    });
    stream.on('end', resolve);
    stream.on('error', reject);
  });

}


exports.postImport = async function (
  source_path,
  secret,
  destination_db,
  destination_username,
  destination_password
) {

  if (!fs.existsSync(source_path)) {
    throw (errorApi.create404Error(source_path));
  }

  var importId = uuidv4();

  var importPath = snapshotDirectory + importedDirectory + "/" + importId;
  var schemaPath = importPath + "/" + schemaFilename;

  console.log("creating import directory structure");

  try {
    fs.mkdirSync(importPath);
  } catch (err) {
    throw (errorApi.create500Error("Error creating temporary import structure: \n" + JSON.stringify(err, null, 2)));
  }

  console.log("extracting and decompressing");
  try {
    await unlockAndDecompress(source_path, secret, importPath)
  } catch (err) {
    console.log(err);
    await fs.remove(importPath);
    throw (errorApi.create500Error("Error extracting. Output: \n" + err.stderr));
  };

  console.log("dropping and re-creating local DB");
  try {
    await dbApi.initialise(destination_db, destination_username, destination_password, schemaPath);
  } catch (err) {
    await fs.remove(importPath);
    throw (errorApi.create500Error("Error creating database: \n" + err.message));
  }
  
  console.log("streaming .csv files");
  try {
    await dbApi.copyFilesToTables(importPath);
  } catch (err) {
    await fs.remove(importPath);
    throw (errorApi.create500Error("Error populating database: \n" + err.message));
  }

  console.log("clearing up");
  try {
    await fs.remove(importPath);
  } catch (err) {
    throw (errorApi.create500Error("Error clearing old files: \n" + err.message));
  }

}




