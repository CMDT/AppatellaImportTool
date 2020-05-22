'use strict';



const errorApi = require('../error/error');
const mkdirp = require('mkdirp');
const fs = require('fs-extra');
const Sql = require('../sql/sql');
const dbApi = require('../database/database');
const definitions = require('../definitions/definitions');

const fsdef = definitions.fileSystem;


const OUTPUT_FILE_EXTENSION = fsdef.outputFileExtension;
const COLUMN_HEADER_COURSES = fsdef.columnHeader_Courses;
const COL_DELIMITER = fsdef.colDelimiter;
const LINE_DELIMITER = fsdef.lineDelimiter;



function createCourseSelectionTableSpec(){
    return dbApi.createTableSpec(
        'temp_selected_courses', 
        dbApi.createTextColumnSpecs(
            [
                'id'
            ]));
};


// function createCourseOutcomeTableSpec(){
//     return dbApi.createTableSpec(
//         'temp_unordered_course_outcomes',
//         dbApi.createTextColumnSpecs(
//         [
//             'course'
//             ,'question_text'
//             ,'day_count'
//             ,'date'
//             ,'answer_choices'
//             ,'selected_choice'
//             ,'answer_text'            
//         ]));
// };

function createCoursesList(arrayRequestedCourses, outputFilePath){ //throws
if (arrayRequestedCourses) {
    //write courseids to a csv file.
    let data = dbApi.createDelimitedTableContent(
      [COLUMN_HEADER_COURSES],
      [arrayRequestedCourses],
      COL_DELIMITER,
      LINE_DELIMITER);
    fs.appendFileSync(outputFilePath, data);
  }
}


/**
 * Exports course-specific data extraction
 * @param {*} parameters - parameters matching that of the analysis definition
 * @param {*} workingPath - path to an empty directory which can b used for constructing temporary data files.
 * @param {*} outputPath  - path to an empty directory into which output can be saved
 * @param {*} fnMessages - async function which can be called periodically to send progress messages - argument is a message string;
 */
async function exportCourseOutcomeAnswers(parameters, workingPath, outputPath, fnMessages){ // throws
    
    const COURSE_SELECTION_FILENAME = 'courses' + OUTPUT_FILE_EXTENSION;
    const COURSE_SELECTION_PATH =  workingPath + '/' + COURSE_SELECTION_FILENAME;
    
    
    await fnMessages("checking course export");

    // create a .csv file, from which we can import a set of course ids as a temporary table
    

    var courseIds = [];
    try{ 
        // can get course ids from parameters
        courseIds = parameters.course_ids;
    }catch(e){} // throws if this parameter is undefined - normal

    
    if (courseIds.length == 0) { 
        // no course ids in parameters - get a list of all shared courses from the dB
        await dbApi.singleQueryToFile(Sql.prepareQueryForCopyTo(Sql.createListSharedCoursesQuery()), COURSE_SELECTION_PATH);
    }else{
        // course ids defined in parameters.
        createCoursesList(courseIds, COURSE_SELECTION_PATH);
    }
  
    await fnMessages("running analysis");  
    
    var analysisQueries = Sql.createCourseOutcomeAnswersQueries();

    await dbApi.exportQueriesToFiles(
        Sql.prepareQueryArrayForCopyTo(analysisQueries), 
        createCourseSelectionTableSpec(),
        COURSE_SELECTION_PATH, 
        outputPath, 
        OUTPUT_FILE_EXTENSION, 
        async function(index, count, name){
            var message = "Running: " + name + " : " + index + " of " + count;
            await fnMessages(message);
      });
  
}

/**
 * Exports course-specific data extraction
 * @param {*} parameters - parameters matching that of the analysis definition
 * @param {*} workingPath - path to an empty directory which can b used for constructing temporary data files.
 * @param {*} outputPath  - path to an empty directory into which output can be saved
 * @param {*} fnMessages - async function which can be called periodically to send progress messages - argument is a message string;
 */
async function exportCourseSessionAnswers(parameters, workingPath, outputPath, fnMessages){ // throws
    
    const COURSE_SELECTION_FILENAME = 'courses' + OUTPUT_FILE_EXTENSION;
    const COURSE_SELECTION_PATH =  workingPath + "/" + COURSE_SELECTION_FILENAME;

    // send output message 
    await fnMessages("checking course export");
    // create a .csv file, from which we can import a set of course ids as a temporary table

    // parameters may hold a set of course ids which have been selected by the client
    var courseIds = [];
    try{
        courseIds = parameters.course_ids;
    }catch(e){} // throws if this parameter is undefined - normal


    if (courseIds.length == 0) { // by default, get ALL authorised courses
        // export these course ids ONLY if they are shared.
        await dbApi.singleQueryToFile(Sql.prepareQueryForCopyTo(Sql.createListSharedCoursesQuery()), COURSE_SELECTION_PATH);
    }else{
        // export ALL shared course ids.
        createCoursesList(courseIds, COURSE_SELECTION_PATH);
    }

    // send output message to export config file
    await fnMessages("running queries");

    // Sql class generates a set of queries which output, based on 
    var queries = Sql.createCourseSessionAnswersQueries();
    await dbApi.exportQueriesToFiles(
        Sql.prepareQueryArrayForCopyTo(queries), 
        createCourseSelectionTableSpec(),
        COURSE_SELECTION_PATH, 
        outputPath, 
        OUTPUT_FILE_EXTENSION, 
        async function(index, count, name){
            var message = "Running: " + name + " : " + index + " of " + count;
            await fnMessages(message);
      });


    await fnMessages("Done.");

}

/**
 * Exports course-specific data extraction
 * @param {*} parameters - parameters matching that of the analysis definition
 * @param {*} workingPath - path to an empty directory which can b used for constructing temporary data files.
 * @param {*} outputPath  - path to an empty directory into which output can be saved
 * @param {*} fnMessages - async function which can be called periodically to send progress messages - argument is a message string;
 */
async function exportCourseSessionCompletion(parameters, workingPath, outputPath, fnMessages){ // throws
    
    const COURSE_SELECTION_FILENAME = 'courses' + OUTPUT_FILE_EXTENSION;
    const COURSE_SELECTION_PATH =  workingPath + "/" + COURSE_SELECTION_FILENAME;

    // send output message 
    await fnMessages("checking course export");
    // create a .csv file, from which we can import a set of course ids as a temporary table

    // parameters may hold a set of course ids which have been selected by the client
    var courseIds = [];
    try{
        courseIds = parameters.course_ids;
    }catch(e){
        console.log("courseIds parameter was unavailable. Collecting all valid courses.");
    } // throws if this parameter is undefined - normal


    if (!courseIds || courseIds.length == 0) { // by default, get ALL authorised courses
        // export these course ids ONLY if they are shared.
        await dbApi.singleQueryToFile(Sql.prepareQueryForCopyTo(Sql.createListSharedCoursesQuery()), COURSE_SELECTION_PATH);
    }else{
        // export ALL shared course ids.
        createCoursesList(courseIds, COURSE_SELECTION_PATH);
    }

    // send output message to export config file
    await fnMessages("running queries");

    // Sql class generates a set of queries which output, based on 
    var queries = Sql.createCourseSessionCompletionQueries();
    await dbApi.exportQueriesToFiles(
        Sql.prepareQueryArrayForCopyTo(queries), 
        createCourseSelectionTableSpec(),
        COURSE_SELECTION_PATH, 
        outputPath, 
        OUTPUT_FILE_EXTENSION, 
        async function(index, count, name){
            var message = "Running: " + name + " : " + index + " of " + count;
            await fnMessages(message);
      });


    await fnMessages("Done.");

}


/**
 * Exports courses and their dependencies, such that a new database can be created, on which all functions can be run.
 * @param {*} parameters - parameters matching that of the analysis definition
 * @param {*} workingPath - path to an empty directory which can b used for constructing temporary data files.
 * @param {*} outputPath  - path to an empty directory into which output can be saved
 * @param {*} fnMessages - async function which can be called periodically to send progress messages - argument is a message string;
 */
async function exportCourses(parameters, workingPath, outputPath, fnMessages){ // throws
    
    const COURSE_SELECTION_FILENAME = 'courses' + OUTPUT_FILE_EXTENSION;
    const COURSE_SELECTION_PATH =  workingPath + "/" + COURSE_SELECTION_FILENAME;

    // send output message 
    await fnMessages("checking course export");
    // create a .csv file, from which we can import a set of course ids as a temporary table

    // parameters may hold a set of course ids which have been selected by the client
    var courseIds = [];
    try{
        courseIds = parameters.course_ids;
    }catch(e){} // throws if this parameter is undefined - normal


    if (courseIds.length == 0) { // by default, get ALL authorised courses
        // export these course ids ONLY if they are shared.
        await dbApi.singleQueryToFile(Sql.prepareQueryForCopyTo(Sql.createListSharedCoursesQuery()), COURSE_SELECTION_PATH);
    }else{
        // export ALL shared course ids.
        createCoursesList(courseIds, COURSE_SELECTION_PATH);
    }

    // send output message to export config file
    await fnMessages("running queries");

    // Sql class generates a set of queries which output, based on 
    var queries = Sql.createCourseDumpQueries();
    await dbApi.exportQueriesToFiles(
        Sql.prepareQueryArrayForCopyTo(queries), 
        createCourseSelectionTableSpec(),
        COURSE_SELECTION_PATH, 
        outputPath, 
        OUTPUT_FILE_EXTENSION, 
        async function(index, count, name){
            var message = "Running: " + name + " : " + index + " of " + count;
            await fnMessages(message);
      });

    await fnMessages("Done.");

}



module.exports = {
    exportCourses: exportCourses,
    exportCourseSessionAnswers,exportCourseSessionCompletion,
    exportCourseSessionAnswers,exportCourseSessionAnswers,
    exportCourseOutcomeAnswers: exportCourseOutcomeAnswers
}