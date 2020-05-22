-- temp_selected_courses is a temporary table
-- it contains the column 'id'
-- id is a column of course ids which are designated as 'shared'.
select t1.id, t1.state, t1.version, TO_CHAR(created,'YYYY-MM-DD HH24:MI:SS.US') created, t1.data_version from courses t1 inner join temp_selected_courses t2 on (t1.id = t2.id);