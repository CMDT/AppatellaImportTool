-- temp_selected_courses is a temporary table
-- it contains the column 'id'
-- id is a column of course ids which are designated as 'shared'.
-- lists the media mappings for all temp_selected_courses
select distinct t5.*
from temp_selected_courses t1 join course_to_plan_mapping t2 on (t1.id = t2.course)
inner join plan_to_session_mapping t3 on (t2.plan = t3.plan)
inner join session_to_exercise_mapping t4 on (t3.session = t4.session)
inner join exercise_to_media_mapping t5 on (t4.exercise = t5.exercise);