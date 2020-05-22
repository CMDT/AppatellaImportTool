-- Description lists the settings_definition_to_settings_mapping table
-- for all entries associated with the template plans used by the selected courses
-- template plans *can* have associated settings, but this is not mandatory.
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
),
get_settings_definitions as (
	select t1.* from settings_definitions t1 inner join get_plans_to_settings_definition_mapping t2 on t2.definition = t1.id
),
get_setting_definition_to_setting_mapping as (
	select t1.* from setting_definition_to_setting_mapping t1 inner join get_settings_definitions t2 on t2.id = t1.definition
)
select * from get_setting_definition_to_setting_mapping;
