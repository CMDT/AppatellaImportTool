with 
get_supported_share_states as (
    select * from share_states where id = 3
),
get_shared_courses as (
    select t1.id from temp_selected_courses t1 inner join shared t2 on (t1.id = t2.id_of_shared_entity) inner join get_supported_share_states t3 on (t2.state =  t3.id)
),
get_course_answers as (
select 
t1.id, 
t1.course,
t1.day_count, 
TO_CHAR(t1.date,'YYYY-MM-DD HH24:MI:SS.US') "date", 
t1.question, 
t1.answer_text, 
substring(t1.json_array_int_choice_indices,'[0-9]+') selected_choice 
from course_answers t1 
inner join get_shared_courses t2 on t1.course = t2.id
),
get_answers_w_questions as (
select 
t1.course, 
t1.day_count,
t1.date,
concat('...' ,right ( regexp_replace (regexp_replace (t2."text",E'[^a-zA-Z0-9]',' ','g'), '( ){2,}',' ','g'), 20)) question_text, 
regexp_replace(regexp_replace (t2."json_array_string_choices",'[^a-zA-Z0-9+-]',' ','g'), '( ){2,}','/','g') answer_choices,
t1.answer_text,
t1.selected_choice 
from get_course_answers t1 
join questions t2 
on (t1.question = t2.id)
)
select course, question_text,  day_count, date, answer_choices, selected_choice, answer_text from get_answers_w_questions order by course, question_text, day_count ASC, date ASC;


