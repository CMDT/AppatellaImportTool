-- temp_selected_courses is a temporary table
-- it contains the column 'id'
-- id is a column of course ids which are designated as 'shared'.
with mapping as (
select id, course, plan, TO_CHAR(created,'YYYY-MM-DD HH24:MI:SS.US') created, TO_CHAR(completed,'YYYY-MM-DD HH24:MI:SS.US') completed from course_to_plan_mapping
)
select t1.* from mapping t1 inner join temp_selected_courses t2 on t1.course = t2.id;