-- temp_selected_courses is a temporary table
-- it contains the column 'id'
-- id is a column of course ids which are designated as 'shared'.
-- Description lists the exercises for a particular course
select distinct t5.id, t5.name, t5.description, t5.instructions, t5.duration_s, t5.description_resource, t5.instructions_resource
from temp_selected_courses t1 join course_to_plan_mapping t2 on (t1.id = t2.course)
inner join plan_to_session_mapping t3 on (t2.plan = t3.plan)
inner join session_to_exercise_mapping t4 on (t3.session = t4.session)
inner join exercises t5 on (t4.exercise = t5.id);