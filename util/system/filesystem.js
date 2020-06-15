'use strict';
const fs = require('fs-extra');

const definitions = {
    outputFileExtension: ".csv",
    zipExtension: ".7z",
    configFileName: 'config.json',
    courseSelectionFilename: 'courses' + this.outputFileExtension,
    readmeFilename: 'readme.md',
    schemaFilename: 'schema.sql',
    functionDescriptionFilename : 'function.md',
    snapshotDirectory: process.cwd() + "/snapshots",
    reservedDirectory: "/reserved",
    exportedDirectory: "/exported", // directory in which to export snapshot data
    importedDirectory: "/imported", // directory in which to upload snapshot data
    workingDirectory: "/working", // directory in which to put function-specific working files.
}

const snapshotDirectory = definitions.snapshotDirectory;
const importedDirectory = definitions.importedDirectory; // directory in which to upload snapshot data


function initialise(){

    function createStructure() {
      // ... and rebuild an empty structure
      fs.mkdirSync(snapshotDirectory);
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