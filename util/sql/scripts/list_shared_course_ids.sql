with get_supported_share_states as (
    select * from share_states where id = 3
),
get_shared_courses as (
    select t1.id from courses t1 inner join shared t2 on (t1.id = t2.id_of_shared_entity) inner join get_supported_share_states t3 on (t2.state =  t3.id)
)
select id from get_shared_courses;