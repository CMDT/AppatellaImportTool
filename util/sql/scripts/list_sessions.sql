-- temp_selected_courses is a temporary table
-- it contains the column 'id'
-- id is a column of course ids which are designated as 'shared'.
-- Description lists items from the sessions table for a particular course
with
get_shared_sessions as ( 
select distinct t4.*
from temp_selected_courses t1 join course_to_plan_mapping t2 on (t1.id = t2.course)
inner join plan_to_session_mapping t3 on (t2.plan = t3.plan)
inner join sessions t4 on (t3.session = t4.id)
),
get_template_sessions as (
select  distinct t1.*
from sessions t1 inner join get_shared_sessions t2 on (t1.id = t2.based_on)
),
all_sessions as (
	select * from get_shared_sessions
	union
	select * from get_template_sessions
)
select * from all_sessions;