'use strict';



module.exports = {

    fileSystem:{
        outputFileExtension: ".csv",
        zipExtension: ".7z",
        configFileName: 'config.json',
        courseSelectionFilename: 'courses' + this.outputFileExtension,
        readmeFilename: 'readme.md',
        functionDescriptionFilename : 'function.md',
        snapshotDirectory: "./snapshots",
        reservedDirectory: "/reserved",
        exportedDirectory: "/exported", // directory in which to export snapshot data
        importedDirectory: "/imported", // directory in which to upload snapshot data
        workingDirectory: "/working", // directory in which to put function-specific working files.


        columnHeader_Courses: "id",
        colDelimiter: ',',
        lineDelimiter: '\n',
        export_request_prefix: "expr_",

        

    } 

}