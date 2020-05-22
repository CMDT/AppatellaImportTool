-- Description lists the plan_to_settings_definition_mapping table
-- for all entries associated with the template plans used by the selected courses
-- template plans *ca* be associated with a settings definition, but this is not mandatory.
-- Parameters: none
with
get_template_plans as (
	select * from plans t1 where t1.based_on is null
),
get_shared_plans as (
	select * from plans t1 inner join course_to_plan_mapping t2 on t1.id = t2.plan inner join temp_selected_courses t3 on t2.course = t3.id
),
get_shared_template_plans as (
	select distinct t1.id from get_template_plans t1 inner join get_shared_plans t2 on t1.id = t2.based_on
),
get_plans_to_settings_definition_mapping as (
	select t1.* from plan_to_setting_definition_mapping t1 inner join get_shared_template_plans t2 on t1.plan = t2.id
)
select * from get_plans_to_settings_definition_mapping;