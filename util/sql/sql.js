'use strict';

var dbApi = require('../database/database');
var genApi = require('./querygen/gen')(__dirname + "/scripts");

class Sql {
   

    static async getAllSharedEntities() {
        var result = [];
      
        var query = genApi.gen("list_all_shared_entities", []);
        var response = await dbApi.query(query.text, query.values);
        if (response.rows.length > 0) {
            result = response.rows;
        }

        return result;
      
      }

    static createTableQuery(tableName, query) {
        var result = dbApi.createTabularQuery(query);
        result.name = tableName;
        return result;
    }


    static createCourseOutcomeAnswersQueries(){
        var result = [];
        result.push(Sql.createTableQuery("course_outcome_answers", genApi.gen("func_all_outcome_answers")));
        return result;        
    }


    static createCourseOutcomeAnswersQueriesOrdered(){
        var result = [];
        result.push(Sql.createTableQuery("course_outcome_answers", genApi.gen("func_all_outcome_answers_ordered")));
        return result;        
    }

    static createCourseSessionAnswersQueries(){
        var result = [];
        result.push(Sql.createTableQuery("courses", genApi.gen("list_courses")));
        result.push(Sql.createTableQuery("course_session_answers", genApi.gen("func_all_session_answers")));
        return result;
    }
    static createCourseSessionCompletionQueries(){
        var result = [];
        result.push(Sql.createTableQuery("courses", genApi.gen("list_courses")));
        result.push(Sql.createTableQuery("course_session_completion", genApi.gen("func_all_session_completion")));
        return result;
    }


    static createCourseDumpQueries() {

        var result = [];
        result.push(Sql.createTableQuery("courses", genApi.gen("list_courses")));
        result.push(Sql.createTableQuery("shared", genApi.gen("list_all_shared_entities")));
        result.push(Sql.createTableQuery("course_answers", genApi.gen("list_course_answers")));
        result.push(Sql.createTableQuery("course_state_types", genApi.gen("list_course_state_types")));
        result.push(Sql.createTableQuery("course_survey_schedule", genApi.gen("list_course_survey_schedule")));
        result.push(Sql.createTableQuery("course_to_plan_mapping", genApi.gen("list_course_to_plan_mapping")));
        result.push(Sql.createTableQuery("course_to_survey_mapping", genApi.gen("list_course_to_survey_mapping")));
        result.push(Sql.createTableQuery("course_to_survey_types", genApi.gen("list_course_to_survey_types")));
        result.push(Sql.createTableQuery("days_of_the_week", genApi.gen("list_days_of_the_week")));
        result.push(Sql.createTableQuery("exercise_to_media_mapping", genApi.gen("list_exercise_to_media_mapping")));
        result.push(Sql.createTableQuery("exercises", genApi.gen("list_exercises")));
        result.push(Sql.createTableQuery("base64_resources", genApi.gen("list_base64_resources")));
        result.push(Sql.createTableQuery("flow_action_types", genApi.gen("list_flow_action_types")));
        result.push(Sql.createTableQuery("media", genApi.gen("list_media")));
        result.push(Sql.createTableQuery("media_context_types", genApi.gen("list_media_context_types")));
        result.push(Sql.createTableQuery("message_types", genApi.gen("list_message_types")));
        result.push(Sql.createTableQuery("messages", genApi.gen("list_messages")));
        result.push(Sql.createTableQuery("period_type", genApi.gen("list_period_type")));
        result.push(Sql.createTableQuery("plan_to_session_mapping", genApi.gen("list_plan_to_session_mapping")));
        result.push(Sql.createTableQuery("plans", genApi.gen("list_plans")));
        result.push(Sql.createTableQuery("question_types", genApi.gen("list_question_types")));
        result.push(Sql.createTableQuery("questions", genApi.gen("list_questions")));
        result.push(Sql.createTableQuery("section_to_question_mapping", genApi.gen("list_section_to_question_mapping",)));
        result.push(Sql.createTableQuery("sections", genApi.gen("list_sections")));
        result.push(Sql.createTableQuery("session_answers", genApi.gen("list_session_answers")));
        result.push(Sql.createTableQuery("session_completion", genApi.gen("list_session_completion")));
        result.push(Sql.createTableQuery("session_to_break_mapping", genApi.gen("list_session_to_break_mapping")));
        result.push(Sql.createTableQuery("session_to_exercise_mapping", genApi.gen("list_session_to_exercise_mapping")));
        result.push(Sql.createTableQuery("session_to_message_mapping", genApi.gen("list_session_to_message_mapping")));
        result.push(Sql.createTableQuery("session_to_survey_mapping", genApi.gen("list_session_to_survey_mapping")));
        result.push(Sql.createTableQuery("session_to_survey_types", genApi.gen("list_session_to_survey_types")));
        result.push(Sql.createTableQuery("sessions", genApi.gen("list_sessions")));
        result.push(Sql.createTableQuery("survey_actions", genApi.gen("list_survey_actions")));
        result.push(Sql.createTableQuery("survey_flows", genApi.gen("list_survey_flows")));
        result.push(Sql.createTableQuery("survey_to_section_mapping", genApi.gen("list_survey_to_section_mapping")));
        result.push(Sql.createTableQuery("surveys", genApi.gen("list_surveys")));
        result.push(Sql.createTableQuery("plan_to_setting_definition_mapping", genApi.gen("list_plan_to_setting_definition_mapping")));
        result.push(Sql.createTableQuery("setting_definition_to_setting_mapping", genApi.gen("list_setting_definition_to_setting_mapping")));
        result.push(Sql.createTableQuery("settings_definitions", genApi.gen("list_settings_definitions")));
        result.push(Sql.createTableQuery("settings", genApi.gen("list_settings")));
        result.push(Sql.createTableQuery("supported_settings", genApi.gen("list_supported_settings")));
        result.push(Sql.createTableQuery("course_answers", genApi.gen("list_course_answers")));
        result.push(Sql.createTableQuery("session_answers", genApi.gen("list_session_answers")));
        result.push(Sql.createTableQuery("session_completion", genApi.gen("list_session_completion")));
        return result;
    }

    static createListSharedCoursesQuery(){
        return genApi.gen("list_shared_course_ids");
    }


    static createCourseDataMultiQuery(courseId) {
        var result = [];
        result.push(Sql.createTableQuery("course_answers", genApi.gen("list_course_answers", [courseId])));
        result.push(Sql.createTableQuery("session_answers", genApi.gen("list_session_answers", [courseId])));
        result.push(Sql.createTableQuery("session_completion", genApi.gen("list_session_completion", [courseId])));
        return result;
    };


    static removeComments(sql) {
        sql = sql.replace(/("(""|[^"])*")|('(''|[^'])*')|(--[^\n\r]*)|(\/\*[\w\W]*?(?=\*\/)\*\/)/gm, function (match) {
            if (
                (match[0] === '"' && match[match.length - 1] === '"')
                || (match[0] === "'" && match[match.length - 1] === "'")
            ) return match;

            return '';
        });

        return sql;
    };

    static minify(sql) {

        sql = sql.replace(/("(""|[^"])*")|('(''|[^'])*')|([\t\r\n])/gm, function (match) {
            if (
                (match[0] === '"' && match[match.length - 1] === '"')
                || (match[0] === "'" && match[match.length - 1] === "'")
            ) return match;

            return ' ';
        });

        sql = sql.replace(/("(""|[^"])*")|('(''|[^'])*')|([ ]{2,})/gm, function (match) {
            if (
                (match[0] === '"' && match[match.length - 1] === '"')
                || (match[0] === "'" && match[match.length - 1] === "'")
            ) return match;

            return ' ';
        });

        return sql.trim();
    }



    static strip(sql) {
        return Sql.minify(Sql.removeComments(sql));
    };


    static split(str) {

        var result = [];
        var array = str.split(new RegExp("\\s*;\\s*(?=([^']*'[^']*')*[^']*$)"));

        if (array) {
            for (var index = 0; index < array.length; index++) {
                var item = array[index];
                if ((item) && (item.length > 0)) {
                    result.push(item);
                }
            }
        }

        return result;
    }


    static prepareSqlForCopyTo(sql){
        var result = null;
      
        if(sql){
          sql = Sql.strip(sql); // removes comments and whitespace
          if(sql.length > 0){
            if(sql.substr(-1) == ';'){ // removes trailing ';'
              sql = sql.slice(0,-1);
            }
          }
          if(sql.length > 0){
            result = sql;
          }
        }
      
        return result;
      }
      
      
    static prepareQueryForCopyTo(query){
        query.text = Sql.prepareSqlForCopyTo(query.text);
        return query;
    }  

    static prepareQueryArrayForCopyTo(queryArray){
        for(var index = 0; index < queryArray.length; index++){
            Sql.prepareQueryForCopyTo(queryArray[index].query);
        }
        return queryArray;
    }
};


module.exports = Sql;
