'use strict';


const uuidv4 = require('uuid/v4');
const errorApi = require('../error/error');


const Minizip = require('minizip-asm.js'); //locker/unlocker

const Sql = require('../sql/sql');
const dbApi = require('../database/database');

const functionsIndex = require('../functions/functionsIndex');
const filestructure = require('../system/filesystem');

const fs = require('fs-extra');
const path = require('path');
const node7z = require('node-7z');
const sevenBin = require ('7zip-bin');


const fsdef = filestructure.definitions;

const zipExtension = fsdef.zipExtension;

const configFileName = fsdef.configFileName;
const readmeFilename = fsdef.readmeFilename;
const functionDescriptionFilename = fsdef.functionDescriptionFilename;

const snapshotDirectory = fsdef.snapshotDirectory;
const reservedDirectory = fsdef.reservedDirectory;
const exportedDirectory = fsdef.exportedDirectory; // directory in which to export snapshot data
const importedDirectory = fsdef.importedDirectory; // directory in which to upload snapshot data
const workingDirectory = fsdef.workingDirectory; // directory in which to put function specific files use as working data for the export 



const export_request_prefix = fsdef.export_request_prefix;



const STATUS = {
  RESERVED: "RESERVED",
  PROGRESSING: "PROGRESSING",
  EXPORTED: "EXPORTED"
};


/**
 * any exports require a secret
 */
exports.reserveExport = function (secret, anonymise, analysisDef) {


  try {
    var secret = checkSecretValidity(secret);
  } catch (e) {
    throw (errorApi.create400Error("invalid secret"));
  }

  try {
    var analysisDef = checkAnalysisDefValidity(analysisDef);
  } catch (e) {
    throw (errorApi.create400Error("invalid analysis: " + e));
  }

  var anonymise = checkAnonymise(anonymise);



  var exportRequestId = createExportRequestId();
  //create file and save secret etc..
  var exportRequestDir = snapshotDirectory + reservedDirectory + "/" + exportRequestId;

  var cfg = {
    id: exportRequestId,
    secret: secret,
    anonymise: anonymise,
    analysisDef: analysisDef,
    status: STATUS.RESERVED,
    created: (new Date()).getTime(),
    logs: []
  };

  try {

    mkdirp.sync(exportRequestDir);

    var exportWorkingDir = exportRequestDir + workingDirectory;
    mkdirp.sync(exportWorkingDir);

    //write config to json file
    fs.appendFileSync(exportRequestDir + '/' + configFileName, JSON.stringify(cfg, null, 2));

  } catch (e) {
    throw (errorApi.createError(500, "couldn't create the necessary files to make the reservation."));
  }



  return {
    exportRequestId: exportRequestId
  }
}


exports.requestExport = async function (exportRequestId) {
  /* find uuid. find folder of that uuid. get secret. kick off export with specified secret and uuid.
  * save exported files to the uuid directory, then zip with secret.
  */
  var config = await getExportConfig(exportRequestId)

  if (config === undefined) {
    throw (errorApi.createError(404, "failed to find reserved export with that id."));
  } else {
    if (config.status != STATUS.RESERVED) {
      throw (errorApi.create400Error("Export request already attempted on this id."));
    } else {
      //perfect request - start export
      exportSnapshot(config);

      return {
        message: "Export process has begun. Check the progress using exportProgress interface.",
        exportRequestId: exportRequestId
      }
    }
  }
}

exports.getExportProgress = async function (exportRequestId) {
  /**
   * return either the progress and fileId if available of the export.
   */
  var config = await getExportConfig(exportRequestId)

  if (config === undefined) {
    throw (errorApi.createError(404, "failed to find reserved export with that id."));
  } else {
    if (config.status == STATUS.RESERVED) {
      throw (errorApi.create400Error("Export not yet requested."));
    } else {
      //perfect request - start export
      var progressObj = {};
      if (config.status) {
        progressObj.status = config.status
      }

      if (config.progress) {
        progressObj.progress = config.progress
      }

      if (config.status == STATUS.EXPORTED) {
        progressObj.fileId = config.fileId;
      }

      return progressObj
    }
  }
}

exports.getExport = async function (fileId, res) {
  var file = fileId + zipExtension;
  var filePath = snapshotDirectory + exportedDirectory + "/" + fileId + "/";
  var lockedFile = "locked" + zipExtension

  if (!fs.existsSync(filePath)) {
    throw (errorApi.createError(404, "failed to find reserved export with that id."));
  } else {

    res.writeHead(200, {
      "Content-Type": "application/octet-stream",
      "Content-Description": "File Transer",
      "Content-Disposition": "attachment; filename=" + file,
      "Access-Control-Expose-Headers": "Content-Type,Content-Description,Content-Disposition"
    });

    var filestream = fs.createReadStream(filePath + lockedFile);
    filestream.pipe(res);
  }
}

exports.deleteExport = async function (fileId, exportRequestId) {
  if ((!fileId) && (!exportRequestId)) {
    throw (errorApi.create400Error("Must provide either a fileID OR an exportRequestId."));
  } else if ((fileId) && (exportRequestId)) {
    throw (errorApi.create400Error("Must provide either a fileID OR an exportRequestId. Not Both."));
  } else {
    var messageObj = {
      messages: []
    }
    if (fileId) {
      var fileDir = snapshotDirectory + exportedDirectory + "/" + fileId;
      if (fs.existsSync(fileDir)) {
        fs.remove(fileDir);
        messageObj.messages.push('successfully deleted export with fileId: ' + fileId);
      } else {
        throw (errorApi.createError(404, "failed to find export with fileId: " + fileId));
      }
    }
    if (exportRequestId) {
      var fileDir = snapshotDirectory + reservedDirectory + "/" + exportRequestId
      if (fs.existsSync(fileDir)) {
        fs.remove(fileDir);
        messageObj.messages.push('successfully deleted reserved snapshot with exportRequestId: ' + exportRequestId);
      } else {
        throw (errorApi.createError(404, "failed to find reserved export with exportRequestId: " + exportRequestId));
      }
    }
    return messageObj
  }
}






exports.postImport = async function (source_path, secret, destination_db) {

  if(!fs.existsSync(source_path)){
    throw(errorApi.create404Error(source_path));
  }

  var importId = uuidv4();
  
  var importPath = snapshotDirectory + importedDirectory + "/" + importId; 

  try {
    fs.mkdirSync(importPath);
  } catch (err) {
    throw(errorApi.create500Error("Error creating temporary import structure: \n" + JSON.stringify(err,null,2)));
  }

  try{
    await unlockAndDecompress(source_path, secret, importPath)
  }catch(err){
    console.log(err)
    throw(errorApi.create500Error("Error extracting. Output: \n" + err.stderr));
  };

  try{
    await dbApi.initialise(destination_db);
  }catch(err){
    throw(errorApi.create500Error("Error creating database: \n" + err.message));
  }

  try{
    await dbApi.copyFilesToTables(importPath);
  }catch(err){
    throw(errorApi.create500Error("Error populating database: \n" + err.message));
  }

  try{
    await fs.remove(importPath);
  }catch(err){
    throw(errorApi.create500Error("Error clearing old files: \n" + err.message));
  }

}



function checkSecretValidity(secret) {
  var result = null;
  if ((secret.length > 3) && (!secret.includes(" "))) {
    result = secret;
  } else {
    throw (new Error("secret must be of minimum length 3, with no spaces."));
  }
  return result;
}

function checkAnonymise(anonymise) {

  var result = true;

  if (anonymise == false) { // must be explicitly set to false to change the default behaviour.
    result = false;
  }

  return result;

}


function checkAnalysisDefValidity(analysisDef) {
  functionsIndex.seekFunction(analysisDef.functionId); // throws

  return analysisDef;
}


async function getExportConfig(exportRequestId) {
  var filePath = snapshotDirectory + reservedDirectory + "/" + exportRequestId + "/" + configFileName;

  try {
    var content = await fs.readFile(filePath, 'utf8');
  } catch (e) {
    var error = { statusCode: 403, message: "failed to find reserved export with the given id." };
    throw (error);
  }

  try {
    var configObj = JSON.parse(content);
  } catch (e) {
    var error = { statusCode: 500, message: "failed to update internal status" };
    throw (error);
  }
  return configObj;
}




function createExportRequestId() {
  var result = "";

  var id = export_request_prefix + (uuidv4().replace(/-/g, '_'));

  result = id;

  return result;
}

async function createFunctionDescriptionFile(functionDef, functionCall, filePath){

    var title = "# Export";
    var name = "## Function: \n" + functionDef.name;
    var description = "## Description: \n" + functionDef.description;
    var call_content = JSON.stringify(functionCall, null, "\t");
    var call = "## Function Call: \n"
    var content = title + "\n" + name + "\n" + description + "\n" + call + "\n```json\n" + call_content + "\n```\n";


    fs.writeFileSync(filePath, content, 'utf8');
}


async function exportSnapshot(config) {
  /**
   * 1. 
   * 2. Get DB Schema >
   * 2. Run all queries
   * 3. store a Mapping of all course_id's with a new uuid
   * 4. find and replace all course_id's with new uuids across all extracted files.
   * 5. zip and lock with secret
   * 6. done.
   */

  var exportRequestId = config.id;


  await updateSnapshotConfig(exportRequestId, 'status', STATUS.PROGRESSING, "Export process begun");


  var outputFilePath = snapshotDirectory + reservedDirectory + "/" + exportRequestId + "/export";
  var exportRequestDir = snapshotDirectory + reservedDirectory + "/" + exportRequestId;
  var exportParametersDir = exportRequestDir + workingDirectory;

  await updateSnapshotConfig(exportRequestId, undefined, undefined, "creating export directory.");

  if (fs.existsSync(outputFilePath)) {
    fs.readdirSync(outputFilePath).forEach(function (file, index) {
      var currentFile = outputFilePath + "/" + file;
      if (fs.lstatSync(currentFile).isDirectory()) { // recurse
        deleteFolderRecursive(currentFile);
      } else { // delete file
        fs.unlinkSync(currentFile);
      }
    });
    fs.rmdirSync(outputFilePath);
  }
  // create a nice new empty one
  fs.mkdirSync(outputFilePath);

  await updateSnapshotConfig(exportRequestId, undefined, undefined, "Copying DB schema");
  await copyFile("./schema/schema.sql", outputFilePath + "/schema.sql");

  await updateSnapshotConfig(exportRequestId, undefined, undefined, "Copying readme file");
  await copyFile("./output_text/readme.md", outputFilePath + "/" + readmeFilename);

  var functionDef = functionsIndex.seekFunction(config.analysisDef.functionId);
  var analysisDef = config.analysisDef;
  await updateSnapshotConfig(exportRequestId, undefined, undefined, "Writing function description");
  createFunctionDescriptionFile(functionDef, analysisDef, outputFilePath + "/" + functionDescriptionFilename);


  await functionsIndex.runFunction(
    exportParametersDir,
    outputFilePath,
    analysisDef,
    async function (message) {
      await updateSnapshotConfig(exportRequestId, undefined, undefined, message);
    }
  );


  await updateSnapshotConfig(exportRequestId, undefined, undefined, "Queries complete.");




  if (config.anonymise != false) {

    await updateSnapshotConfig(exportRequestId, undefined, undefined, "Beginning Anonymisation.");

    var sharedIds = await Sql.getAllSharedEntities();
    var files = fs.readdirSync(outputFilePath);
    for (var i = 0; i < files.length; i++) {
      var file = files[i];
      var filePath = outputFilePath + "/" + file;
      var progress = i * 100 / files.length;
      await updateSnapshotConfig(exportRequestId, "progress", progress, "progress (%): " + progress);
      var data = fs.readFileSync(filePath, 'utf8');

      for (var j = 0; j < sharedIds.length; j++) {

        var find = sharedIds[j].id;
        var regFind = "/" + find + "/g"; // global replace instruction
        var replace = uuidv4();
        data = data.replace(regFind, replace);

      }
      fs.writeFileSync(filePath, data, 'utf8');

    }
  }else{
    await updateSnapshotConfig(exportRequestId, undefined, undefined, "Anonymisation disabled by request.");
  }


  await updateSnapshotConfig(exportRequestId, undefined, undefined, "Zipping...");

  var fileId = await compressAndLock(exportRequestId)
  await updateSnapshotConfig(exportRequestId, "fileId", fileId, undefined);

  await updateSnapshotConfig(exportRequestId, "status", STATUS.EXPORTED, "Fin");//required

  var config = await getExportConfig(exportRequestId);
  console.log(config);

}




async function copyFile(source, target) {
  var cbCalled = false;
  return new Promise((resolve, reject) => {
    var rd = fs.createReadStream(source);
    rd.on("error", function (err) {
      done(err);
    });
    var wr = fs.createWriteStream(target);
    wr.on("error", function (err) {
      done(err);
    });
    wr.on("close", function (ex) {
      done();
    });
    rd.pipe(wr);

    function done(err) {
      if (!cbCalled) {
        cbCalled = true;
        if (err) {
          reject(err)
        } else {
          resolve()
        }
      }
    }
  })
}

async function updateSnapshotConfig(exportRequestId, property, value, logMessage) {
  var config = await getExportConfig(exportRequestId)
  var changelog = ""
  if (property && value) {
    if (typeof property === 'string' || property instanceof String) {
      config[property] = value;
      var changelog = " - [" + property + " CHANGED TO: " + value + "]"
    }
  }
  if (logMessage) {
    config.logs.push(new Date() + " : " + logMessage + changelog);
  } else {
    config.logs.push(new Date() + " : " + changelog);
  }

  return new Promise((resolve, reject) => {
    var exportRequestDir = snapshotDirectory + reservedDirectory + "/" + exportRequestId;
    fs.writeFile(exportRequestDir + '/' + configFileName, JSON.stringify(config, null, 2), function (err) {
      if (err) {
        // append failed
        reject(err)
      } else {
        // done
        resolve();
      }
    })
  })
}

async function compressAndLock(exportRequestId) {
  var fileId = uuidv4(); // id where the export will be zipped to.

  const reserveFolderDirectory = snapshotDirectory + reservedDirectory + "/" + exportRequestId + "/export/";
  const exportFolderDirectory = snapshotDirectory + exportedDirectory + "/" + fileId;
  const secret = (await getExportConfig(exportRequestId)).secret;

  return new Promise(async (resolve, reject) => {
    try {
      fs.mkdirSync(exportFolderDirectory);
      var myZip = new Minizip();

      //push all files to myZip with password
      await updateSnapshotConfig(exportRequestId, undefined, undefined, "Pushing files to export"); //log
      fs.readdirSync(reserveFolderDirectory).forEach((file, index, files) => {
        var text = fs.readFileSync(reserveFolderDirectory + file);
        myZip.append("/" + file, text, { password: secret });

        //await updateSnapshotConfig(exportRequestId, "progress", Math.floor((((index+1) / files.length)* 50)+50)+"%", "A file was appended to the export."); //log
        // unable to await in this loop, unsure why.
      });
      await updateSnapshotConfig(exportRequestId, "progress", "100%", "All files were appended to the export."); //log


      //save zip
      fs.writeFileSync(exportFolderDirectory + "/locked" + zipExtension, new Buffer(myZip.zip()));

      resolve(fileId)
    } catch (err) {
      reject(err)
    }
  });
}

function unlockAndDecompress(sourcePath, secret, destinationPath) {

  return new Promise(function(resolve, reject){
    
    const pathTo7zip = sevenBin.path7za
    const stream = node7z.extractFull(sourcePath, destinationPath, {
      $bin: pathTo7zip,
      password: secret,
      recursive: true
    });

    stream.on('data', function(data){
      console.log(data.file);
    });
    stream.on('end', resolve);
    stream.on('error', reject);
  
  });

}
