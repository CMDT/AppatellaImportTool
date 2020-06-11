'use strict';
const mkdirp = require('mkdirp');
const fs = require('fs-extra');

const definitions = {
    outputFileExtension: ".csv",
    zipExtension: ".7z",
    configFileName: 'config.json',
    courseSelectionFilename: 'courses' + this.outputFileExtension,
    readmeFilename: 'readme.md',
    schemaFilename: 'schema.sql',
    functionDescriptionFilename : 'function.md',
    snapshotDirectory: "./snapshots",
    reservedDirectory: "/reserved",
    exportedDirectory: "/exported", // directory in which to export snapshot data
    importedDirectory: "/imported", // directory in which to upload snapshot data
    workingDirectory: "/working", // directory in which to put function-specific working files.
}


const zipExtension = definitions.zipExtension;

const configFileName = definitions.configFileName;
const readmeFilename = definitions.readmeFilename;
const functionDescriptionFilename = definitions.functionDescriptionFilename;


const snapshotDirectory = definitions.snapshotDirectory;
const reservedDirectory = definitions.reservedDirectory;
const exportedDirectory = definitions.exportedDirectory; // directory in which to export snapshot data
const importedDirectory = definitions.importedDirectory; // directory in which to upload snapshot data
const workingDirectory = definitions.workingDirectory; // directory in which to put function specific files use as working data for the export 



const export_request_prefix = definitions.export_request_prefix;


function initialise(){

    function createStructure() {
      // ... and rebuild an empty structure
      fs.mkdirSync(snapshotDirectory);
      fs.mkdirSync(snapshotDirectory + reservedDirectory);
      fs.mkdirSync(snapshotDirectory + exportedDirectory);
      fs.mkdirSync(snapshotDirectory + importedDirectory);
    }
  
  
    // clear down any snapshots - we will lose them.
    if (fs.existsSync(snapshotDirectory)) {
      fs.remove(snapshotDirectory,
        function (err) {
          if (err) {
            throw (err);
          } else {
            createStructure();
          }
        }); // like rm -rf
    } else {
      createStructure();
    }
  
  }



module.exports = {
    definitions: definitions,
    initialise: initialise
  };