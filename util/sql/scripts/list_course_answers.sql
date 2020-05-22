-- temp_selected_courses is a temporary table
-- it contains the column 'id'
-- id is a column of course ids which are designated as 'shared'.
with answers as (
select id, course, survey, survey_type, section, question, answer_text, json_array_int_choice_indices, day_count, date, TO_CHAR(timestamp,'YYYY-MM-DD HH24:MI:SS.US') "timestamp" from course_answers
)
select t1.* from answers t1 inner join temp_selected_courses t2 on t1.course = t2.id; 