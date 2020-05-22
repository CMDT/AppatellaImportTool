'use strict';


var service = require('./databaseservice');

module.exports = {

    tables:{
        users: {
            name:"users",
            columns:{
                id:"id",
                externalId:"external_id",
                created: "created"
            }
        },
        courses: {
            name:"courses",
            columns:{
                id:"id",
                state: "state",
                version: "version",
                created: "created"
            }
        },
        user_to_course_mapping:{
            name: "user_to_course_mapping",
            columns: {
                id: "id",
                user: "user",
                course: "course"
            }
        },
        deployments:{
            name: "deployments",
            columns:{
                id: "id",
                state: "state",
                course_id: "course_id",
                created: "created"
            } 
        }
        

    },
    constants: {
        COURSE_STATE_TYPES:{
            OPEN: 1,
            CLOSED: 0
        },
        DEPLOYMENT_STATE_TYPES:{
            DOWNLOAD: 0,
            ACTIVE: 1,
            SUSPENDED: 2,
            DEMO: 3
        },
        COURSE_COL: "course",
        NOT_FOUND: -1
    },


  initialise: service.initialise,
  createTableSpec: service.createTableSpec,
  createTextColumnSpecs : service.createTextColumnSpecs,
  createColumnSpec: service.createColumnSpec,
  query: service.query,
  multiQuery: service.multiQuery,
  createTabularQuery: service.createTabularQuery,
  multiTabularQuery: service.multiTabularQuery,
  copyFilesToTables: service.copyFilesToTables,
  singleQueryToFile: service.singleQueryToFile,
  exportQueriesToFiles: service.exportQueriesToFiles,
  createDelimitedTableContent: service.createDelimitedTableContent
  
}



