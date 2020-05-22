-- temp_selected_courses is a temporary table
-- it contains the column 'id'
-- id is a column of course ids which are designated as 'shared'.
with exercise_resources as (
select distinct t6.*
from temp_selected_courses t1 join course_to_plan_mapping t2 on (t1.id = t2.course)
inner join plan_to_session_mapping t3 on (t2.plan = t3.plan)
inner join session_to_exercise_mapping t4 on (t3.session = t4.session)
inner join exercises t5 on (t4.exercise = t5.id)
inner join base64_resources t6 on (t5.description_resource = t6.id OR t5.instructions_resource = t6.id)
),
session_resources as (
select distinct t6.*
from temp_selected_courses t1 join course_to_plan_mapping t2 on (t1.id = t2.course)
inner join plan_to_session_mapping t3 on (t2.plan = t3.plan)
inner join sessions t5 on (t3.session = t5.id)
inner join base64_resources t6 on (t5.description_resource = t6.id OR t5.instructions_resource = t6.id)
),
plan_resources as (
select distinct t6.*
from temp_selected_courses t1 join course_to_plan_mapping t2 on (t1.id = t2.course)
inner join plans t5 on (t2.plan = t5.id)
inner join base64_resources t6 on (t5.description_resource = t6.id OR t5.instructions_resource = t6.id OR t5.diagnostic_resource = t6.id)
),
sum_all as (
    select * from exercise_resources
    union
    select * from session_resources
    union 
    select * from plan_resources
)
select * from sum_all;
