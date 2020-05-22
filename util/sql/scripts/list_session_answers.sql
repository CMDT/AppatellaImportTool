-- temp_selected_courses is a temporary table
-- it contains the column 'id'
-- id is a column of course ids which are designated as 'shared'.
-- Description gets the session answers associated with particular courses
select 
t1.id, 
t1.course, 
t1.plan, 
t1.session, 
t1.session_based_on, 
t1.session_order, 
t1.survey, 
t1.survey_type, 
t1.section, 
t1.question, 
t1.answer_text, 
t1.json_array_int_choice_indices, 
t1.day_count, 
TO_CHAR(date,'YYYY-MM-DD HH24:MI:SS.US') "date", 
TO_CHAR(timestamp,'YYYY-MM-DD HH24:MI:SS.US') "timestamp", 
t1.plan_based_on  
from session_answers t1 inner join temp_selected_courses t2 on (t1.course = t2.id);