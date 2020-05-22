with
get_supported_share_states as (
    select * from share_states where id = 3
),
get_shared_courses as (
    select t1.id from temp_selected_courses t1 inner join shared t2 on (t1.id = t2.id_of_shared_entity) inner join get_supported_share_states t3 on (t2.state =  t3.id)
),
get_session_completion as (
select 
t1.id, 
t1.course,
t1.day_count, 
TO_CHAR(t1.start_timestamp,'YYYY-MM-DD HH24:MI:SS.US') "start_date", 
TO_CHAR(t1.date,'YYYY-MM-DD HH24:MI:SS.US') "date", 
EXTRACT(EPOCH FROM (t1.date - t1.start_timestamp)) "session_duration_s",
t1.session,
t1.plan,
t1.last_attempted_exercise, 
t1.progress_percent

from session_completion t1 
inner join get_shared_courses t2 on t1.course = t2.id
),
get_answers_w_detail as (
select 
t1.course, 
concat('...' ,right ( regexp_replace (regexp_replace (t4.name,E'[^a-zA-Z0-9]',' ','g'), '( ){2,}',' ','g'), 20)) plan_name,
concat('...' ,right ( regexp_replace (regexp_replace (t3.name,E'[^a-zA-Z0-9]',' ','g'), '( ){2,}',' ','g'), 20)) session_name,
concat('...' ,right ( regexp_replace (regexp_replace (t3.name,E'[^a-zA-Z0-9]',' ','g'), '( ){2,}',' ','g'), 20)) last_exercise_name,
t1.day_count,
t1.start_date,
t1.date,
t1.session_duration_s,
t1.progress_percent
from get_session_completion t1 
join exercises t2 
on (t1.last_attempted_exercise = t2.id)
join sessions t3
on (t1.session = t3.id)
join plans t4 
on (t1.plan = t4.id)
)
select course, plan_name, session_name, start_date, date, session_duration_s, last_exercise_name,  day_count, progress_percent from get_answers_w_detail order by course, plan_name, session_name, last_exercise_name, day_count ASC, date ASC;