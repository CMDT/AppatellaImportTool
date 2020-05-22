-- temp_selected_courses is a temporary table
-- it contains the column 'id'
-- id is a column of course ids which are designated as 'shared'.
select t1.* from  course_to_survey_mapping t1 inner join temp_selected_courses t2 on t1.course = t2.id;