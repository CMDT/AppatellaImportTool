-- temp_selected_courses is a temporary table
-- it contains the column 'id'
-- id is a column of course ids which are designated as 'shared'.
-- Description lists items from the surveys table for a particular course
with get_courses as (
select t1.* from courses t1 inner join temp_selected_courses t2 on (t1.id = t2.id)
),
get_from_sessions as (
select distinct t5.*
from get_courses t1 join course_to_plan_mapping t2 on (t1.id = t2.course)
inner join plan_to_session_mapping t3 on (t2.plan = t3.plan)
inner join session_to_survey_mapping t4 on (t3.session = t4.session)
inner join surveys t5 on (t4.survey = t5.id)
),
get_from_course as (
select  distinct t3.*
from get_courses t1 join course_to_survey_mapping t2 on (t1.id = t2.course)
inner join surveys t3 on (t2.survey = t3.id)
)
,
get_from_course_and_session as (
select * from get_from_sessions
UNION
select * from get_from_course
)
select * from get_from_course_and_session;
