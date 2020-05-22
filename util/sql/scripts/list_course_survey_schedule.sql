-- temp_selected_courses is a temporary table
-- it contains the column 'id'
-- id is a column of course ids which are designated as 'shared'.
select distinct t3.*
from temp_selected_courses t1 join course_to_survey_mapping t2 on (t1.id = t2.course)
inner join course_survey_schedule t3 on (t2.id = t3.mapping)



