-- temp_selected_courses is a temporary table
-- it contains the column 'id'
-- id is a column of course ids which are designated as 'shared'.
-- Description lists items from the session_completion table for particular courses
select 
t1.id, 
t1.course, 
t1.plan, 
t1.session, 
t1.session_based_on, 
t1.session_order, 
t1.day_count, 
TO_CHAR(t1.date,'YYYY-MM-DD HH24:MI:SS.US') date, 
t1.last_attempted_exercise, 
t1.exercise_order,
t1.last_attempted_rep, 
t1.num_surveys_completed, 
t1.progress_percent, 
TO_CHAR(t1.timestamp,'YYYY-MM-DD HH24:MI:SS.US') "timestamp", 
t1.plan_based_on 
from session_completion t1 
inner join temp_selected_courses t2 
on (t1.course = t2.id);