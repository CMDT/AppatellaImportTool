-- temp_selected_courses is a temporary table
-- it contains the column 'id'
-- id is a column of course ids which are designated as 'shared'.
-- Description lists items from the plans table for a particular course
with
get_shared_plans as ( 
select  distinct t3.id, t3.based_on, t3.name, t3.description, t3.instructions, TO_CHAR(t3.created,'YYYY-MM-DD HH24:MI:SS.US') created, t3.description_resource, t3.instructions_resource, t3.diagnostic_resource
from temp_selected_courses t1 join course_to_plan_mapping t2 on (t1.id = t2.course)
inner join plans t3 on (t2.plan = t3.id)
),
get_template_plans as (
select  distinct t1.id, t1.based_on, t1.name, t1.description, t1.instructions, TO_CHAR(t1.created,'YYYY-MM-DD HH24:MI:SS.US') created, t1.description_resource, t1.instructions_resource, t1.diagnostic_resource
from plans t1 inner join get_shared_plans t2 on (t1.id = t2.based_on)
),
all_plans as (
	select * from get_shared_plans
	union
	select * from get_template_plans
)
select * from all_plans;