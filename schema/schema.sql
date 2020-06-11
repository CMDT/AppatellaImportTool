--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1
-- Dumped by pg_dump version 12.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: get_course_answers(); Type: FUNCTION; Schema: public; Owner: digitallabsadmin
--

CREATE FUNCTION public.get_course_answers() RETURNS TABLE(course text, question_text text, day_count bigint, date text, answer_choices text, selected_choice integer, answer_text text)
    LANGUAGE sql STABLE
    AS $$
with 
selected_courses as (
	select t1.id from courses t1
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
inner join selected_courses t2 on t1.course = t2.id
),
get_answers_w_questions as (
select 
t1.course, 
t2.text question_text, 
t1.day_count,
t1.date,
t2.json_array_string_choices answer_choices,
t1.answer_text,
(t1.selected_choice::integer +1) as selected_choice
from get_course_answers t1 
join questions t2 
on (t1.question = t2.id)
)
select course, question_text,  day_count, date, answer_choices, selected_choice, answer_text from get_answers_w_questions order by course, question_text, day_count ASC, date ASC;
$$;


ALTER FUNCTION public.get_course_answers() OWNER TO digitallabsadmin;

--
-- Name: get_session_answers(); Type: FUNCTION; Schema: public; Owner: digitallabsadmin
--

CREATE FUNCTION public.get_session_answers() RETURNS TABLE(course text, plan_name text, session_name text, question_text text, day_count integer, date text, answer_choices text, selected_choice integer, answer_text text)
    LANGUAGE sql STABLE
    AS $$
with
selected_courses as (
	select t1.id from courses t1
),
get_session_answers as (
select 
t1.id, 
t1.course,
t1.day_count, 
TO_CHAR(t1.date,'YYYY-MM-DD HH24:MI:SS.US') "date", 
t1.question,
t1.session,
t1.plan, 
t1.answer_text, 
substring(t1.json_array_int_choice_indices,'[0-9]+') selected_choice 
from session_answers t1 
inner join selected_courses t2 on t1.course = t2.id
),
get_answers_w_detail as (
select 
t1.course, 
t4.name plan_name,
t3.name session_name,
t1.day_count,
t1.date,
t2.text question_text,
t2.json_array_string_choices answer_choices,
t1.answer_text,
(t1.selected_choice::integer + 1) as selected_choice
from get_session_answers t1 
join questions t2 
on (t1.question = t2.id)
join sessions t3
on (t1.session = t3.id)
join plans t4 
on (t1.plan = t4.id)
)
select course, plan_name, session_name, question_text,  day_count, date, answer_choices, selected_choice, answer_text from get_answers_w_detail order by course, plan_name, session_name, question_text, day_count ASC, date ASC;
$$;


ALTER FUNCTION public.get_session_answers() OWNER TO digitallabsadmin;

--
-- Name: get_session_completion(); Type: FUNCTION; Schema: public; Owner: digitallabsadmin
--

CREATE FUNCTION public.get_session_completion() RETURNS TABLE(course text, plan_name text, session_name text, start_date text, date text, session_duration_s double precision, last_exercise_name text, day_count integer, progress_percent integer)
    LANGUAGE sql STABLE
    AS $$
with
selected_courses as (
	select t1.id from courses t1
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
inner join selected_courses t2 on t1.course = t2.id
),
get_answers_w_detail as (
select 
t1.course, 
t4.name plan_name, -- concat('...' ,right ( regexp_replace (regexp_replace (t4.name,E'[^a-zA-Z0-9]',' ','g'), '( ){2,}',' ','g'), 20)) plan_name,
t3.name session_name, -- concat('...' ,right ( regexp_replace (regexp_replace (t3.name,E'[^a-zA-Z0-9]',' ','g'), '( ){2,}',' ','g'), 20)) session_name,
t2.name last_exercise_name, -- concat('...' ,right ( regexp_replace (regexp_replace (t3.name,E'[^a-zA-Z0-9]',' ','g'), '( ){2,}',' ','g'), 20)) last_exercise_name,
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
$$;


ALTER FUNCTION public.get_session_completion() OWNER TO digitallabsadmin;

--
-- Name: access_types_id_seq; Type: SEQUENCE; Schema: public; Owner: digitallabsadmin
--

CREATE SEQUENCE public.access_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.access_types_id_seq OWNER TO digitallabsadmin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: base64_resources; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.base64_resources (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    mime_type text,
    data text
);


ALTER TABLE public.base64_resources OWNER TO digitallabsadmin;

--
-- Name: base64_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: digitallabsadmin
--

CREATE SEQUENCE public.base64_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.base64_resources_id_seq OWNER TO digitallabsadmin;

--
-- Name: base64_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: digitallabsadmin
--

ALTER SEQUENCE public.base64_resources_id_seq OWNED BY public.base64_resources.id;


--
-- Name: capability_types; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.capability_types (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE public.capability_types OWNER TO digitallabsadmin;

--
-- Name: capability_types_id_seq; Type: SEQUENCE; Schema: public; Owner: digitallabsadmin
--

CREATE SEQUENCE public.capability_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.capability_types_id_seq OWNER TO digitallabsadmin;

--
-- Name: capability_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: digitallabsadmin
--

ALTER SEQUENCE public.capability_types_id_seq OWNED BY public.capability_types.id;


--
-- Name: course_answers; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.course_answers (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    course text,
    survey text,
    survey_type integer,
    section text,
    question text,
    answer_text text,
    json_array_int_choice_indices text,
    day_count bigint,
    date timestamp without time zone,
    "timestamp" timestamp without time zone DEFAULT timezone('utc'::text, now())
);


ALTER TABLE public.course_answers OWNER TO digitallabsadmin;

--
-- Name: course_state_types; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.course_state_types (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.course_state_types OWNER TO digitallabsadmin;

--
-- Name: course_survey_schedule; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.course_survey_schedule (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    every integer,
    period integer,
    mapping text,
    from_date date DEFAULT ('now'::text)::date
);


ALTER TABLE public.course_survey_schedule OWNER TO digitallabsadmin;

--
-- Name: course_to_plan_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.course_to_plan_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    course text,
    plan text,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()),
    completed timestamp without time zone
);


ALTER TABLE public.course_to_plan_mapping OWNER TO digitallabsadmin;

--
-- Name: course_to_survey_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.course_to_survey_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    course text,
    survey text,
    type integer
);


ALTER TABLE public.course_to_survey_mapping OWNER TO digitallabsadmin;

--
-- Name: course_to_survey_types; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.course_to_survey_types (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.course_to_survey_types OWNER TO digitallabsadmin;

--
-- Name: courses; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.courses (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    state integer DEFAULT 1,
    version bigint DEFAULT '0'::bigint,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()),
    data_version bigint DEFAULT '0'::bigint
);


ALTER TABLE public.courses OWNER TO digitallabsadmin;

--
-- Name: days_of_the_week; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.days_of_the_week (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.days_of_the_week OWNER TO digitallabsadmin;

--
-- Name: exercise_to_media_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.exercise_to_media_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    exercise text,
    media text,
    media_context_type integer
);


ALTER TABLE public.exercise_to_media_mapping OWNER TO digitallabsadmin;

--
-- Name: exercises; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.exercises (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    name text,
    description text,
    instructions text,
    duration_s bigint,
    description_resource text,
    instructions_resource text
);


ALTER TABLE public.exercises OWNER TO digitallabsadmin;

--
-- Name: export_to_course_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.export_to_course_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    export text NOT NULL,
    course text NOT NULL
);


ALTER TABLE public.export_to_course_mapping OWNER TO digitallabsadmin;

--
-- Name: exports; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.exports (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    "user" text,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()),
    filename text NOT NULL,
    downloaded timestamp without time zone
);


ALTER TABLE public.exports OWNER TO digitallabsadmin;

--
-- Name: flow_action_types; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.flow_action_types (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.flow_action_types OWNER TO digitallabsadmin;

--
-- Name: media; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.media (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    url text,
    mime_type text,
    internal text
);


ALTER TABLE public.media OWNER TO digitallabsadmin;

--
-- Name: media_context_types; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.media_context_types (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.media_context_types OWNER TO digitallabsadmin;

--
-- Name: message_types; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.message_types (
    id integer NOT NULL,
    name text,
    description text
);


ALTER TABLE public.message_types OWNER TO digitallabsadmin;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.messages (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    content text,
    type integer
);


ALTER TABLE public.messages OWNER TO digitallabsadmin;

--
-- Name: period_type; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.period_type (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.period_type OWNER TO digitallabsadmin;

--
-- Name: plan_survey_schedule; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.plan_survey_schedule (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    every integer,
    period integer,
    mapping text,
    from_date date DEFAULT ('now'::text)::date
);


ALTER TABLE public.plan_survey_schedule OWNER TO digitallabsadmin;

--
-- Name: plan_to_session_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.plan_to_session_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    plan text,
    session text,
    day integer,
    "order" integer
);


ALTER TABLE public.plan_to_session_mapping OWNER TO digitallabsadmin;

--
-- Name: plan_to_setting_definition_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.plan_to_setting_definition_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    plan text,
    definition text
);


ALTER TABLE public.plan_to_setting_definition_mapping OWNER TO digitallabsadmin;

--
-- Name: plan_to_survey_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.plan_to_survey_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    plan text,
    survey text,
    type integer
);


ALTER TABLE public.plan_to_survey_mapping OWNER TO digitallabsadmin;

--
-- Name: plans; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.plans (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    based_on text,
    name text,
    description text,
    instructions text,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()),
    description_resource text,
    instructions_resource text,
    diagnostic_resource text
);


ALTER TABLE public.plans OWNER TO digitallabsadmin;

--
-- Name: question_types; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.question_types (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.question_types OWNER TO digitallabsadmin;

--
-- Name: questions; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.questions (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    type integer,
    text text,
    json_array_string_choices text
);


ALTER TABLE public.questions OWNER TO digitallabsadmin;

--
-- Name: resource_type; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.resource_type (
    id integer NOT NULL,
    name text NOT NULL,
    mime_type text NOT NULL
);


ALTER TABLE public.resource_type OWNER TO digitallabsadmin;

--
-- Name: resource_type_id_seq; Type: SEQUENCE; Schema: public; Owner: digitallabsadmin
--

CREATE SEQUENCE public.resource_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.resource_type_id_seq OWNER TO digitallabsadmin;

--
-- Name: resource_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: digitallabsadmin
--

ALTER SEQUENCE public.resource_type_id_seq OWNED BY public.resource_type.id;


--
-- Name: section_to_question_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.section_to_question_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    section text,
    question text,
    "order" integer
);


ALTER TABLE public.section_to_question_mapping OWNER TO digitallabsadmin;

--
-- Name: sections; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.sections (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    title text,
    intro_message text
);


ALTER TABLE public.sections OWNER TO digitallabsadmin;

--
-- Name: session_answers; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.session_answers (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    course text,
    plan text,
    session text,
    session_based_on text,
    session_order integer,
    survey text,
    survey_type integer,
    section text,
    question text,
    answer_text text,
    json_array_int_choice_indices text,
    day_count integer,
    date timestamp without time zone,
    "timestamp" timestamp without time zone DEFAULT timezone('utc'::text, now()),
    plan_based_on text
);


ALTER TABLE public.session_answers OWNER TO digitallabsadmin;

--
-- Name: session_completion; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.session_completion (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    course text,
    plan text,
    session text,
    session_based_on text,
    session_order integer DEFAULT 0,
    day_count integer DEFAULT 0,
    date timestamp without time zone,
    last_attempted_exercise text,
    exercise_order integer DEFAULT 0,
    last_attempted_rep integer DEFAULT 0,
    num_surveys_completed integer DEFAULT 0,
    progress_percent integer DEFAULT 0,
    "timestamp" timestamp without time zone DEFAULT timezone('utc'::text, now()),
    plan_based_on text,
    start_timestamp timestamp without time zone
);


ALTER TABLE public.session_completion OWNER TO digitallabsadmin;

--
-- Name: session_to_break_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.session_to_break_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    session text,
    break_s integer,
    "order" integer,
    entry_animation integer,
    exit_animation integer
);


ALTER TABLE public.session_to_break_mapping OWNER TO digitallabsadmin;

--
-- Name: session_to_exercise_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.session_to_exercise_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    session text,
    exercise text,
    reps integer,
    "order" integer,
    entry_animation integer,
    exit_animation integer
);


ALTER TABLE public.session_to_exercise_mapping OWNER TO digitallabsadmin;

--
-- Name: session_to_message_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.session_to_message_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    session text,
    message text,
    "order" integer,
    substitution text,
    duration_s integer DEFAULT 10,
    entry_animation integer,
    exit_animation integer
);


ALTER TABLE public.session_to_message_mapping OWNER TO digitallabsadmin;

--
-- Name: session_to_survey_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.session_to_survey_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    session text,
    survey text,
    type integer
);


ALTER TABLE public.session_to_survey_mapping OWNER TO digitallabsadmin;

--
-- Name: session_to_survey_types; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.session_to_survey_types (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.session_to_survey_types OWNER TO digitallabsadmin;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.sessions (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    based_on text,
    name text,
    description text,
    instructions text,
    description_resource text,
    instructions_resource text
);


ALTER TABLE public.sessions OWNER TO digitallabsadmin;

--
-- Name: setting_definition_to_setting_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.setting_definition_to_setting_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    definition text,
    setting text
);


ALTER TABLE public.setting_definition_to_setting_mapping OWNER TO digitallabsadmin;

--
-- Name: settings; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.settings (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    supported_setting text,
    value text NOT NULL
);


ALTER TABLE public.settings OWNER TO digitallabsadmin;

--
-- Name: settings_definitions; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.settings_definitions (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.settings_definitions OWNER TO digitallabsadmin;

--
-- Name: supported_animations; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.supported_animations (
    id integer NOT NULL,
    name text NOT NULL,
    description text NOT NULL
);


ALTER TABLE public.supported_animations OWNER TO digitallabsadmin;

--
-- Name: supported_settings; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.supported_settings (
    id text NOT NULL,
    friendly_name text NOT NULL,
    type text NOT NULL,
    "default" text
);


ALTER TABLE public.supported_settings OWNER TO digitallabsadmin;

--
-- Name: survey_actions; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.survey_actions (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.survey_actions OWNER TO digitallabsadmin;

--
-- Name: survey_flows; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.survey_flows (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    if_survey_id_is text,
    if_section_id_is text,
    if_question_id_is text,
    array_and_answer_contains_index text,
    array_and_answer_contains_value text,
    then_do_action integer,
    on_question_id text
);


ALTER TABLE public.survey_flows OWNER TO digitallabsadmin;

--
-- Name: survey_to_section_mapping; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.survey_to_section_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    survey text,
    section text,
    "order" integer
);


ALTER TABLE public.survey_to_section_mapping OWNER TO digitallabsadmin;

--
-- Name: surveys; Type: TABLE; Schema: public; Owner: digitallabsadmin
--

CREATE TABLE public.surveys (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    title text,
    intro_message text,
    exit_message text
);


ALTER TABLE public.surveys OWNER TO digitallabsadmin;

--
-- Name: user_to_organisation_mapping_states_id_seq; Type: SEQUENCE; Schema: public; Owner: digitallabsadmin
--

CREATE SEQUENCE public.user_to_organisation_mapping_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_to_organisation_mapping_states_id_seq OWNER TO digitallabsadmin;

--
-- Name: capability_types id; Type: DEFAULT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.capability_types ALTER COLUMN id SET DEFAULT nextval('public.capability_types_id_seq'::regclass);


--
-- Name: resource_type id; Type: DEFAULT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.resource_type ALTER COLUMN id SET DEFAULT nextval('public.resource_type_id_seq'::regclass);


--
-- Name: base64_resources base64_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.base64_resources
    ADD CONSTRAINT base64_resources_pkey PRIMARY KEY (id);


--
-- Name: capability_types capability_types_name_key; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.capability_types
    ADD CONSTRAINT capability_types_name_key UNIQUE (name);


--
-- Name: capability_types capability_types_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.capability_types
    ADD CONSTRAINT capability_types_pkey PRIMARY KEY (id);


--
-- Name: course_answers course_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_answers
    ADD CONSTRAINT course_answers_pkey PRIMARY KEY (id);


--
-- Name: course_state_types course_state_types_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_state_types
    ADD CONSTRAINT course_state_types_pkey PRIMARY KEY (id);


--
-- Name: course_survey_schedule course_survey_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_survey_schedule
    ADD CONSTRAINT course_survey_schedule_pkey PRIMARY KEY (id);


--
-- Name: course_to_plan_mapping course_to_plan_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_to_plan_mapping
    ADD CONSTRAINT course_to_plan_mapping_pkey PRIMARY KEY (id);


--
-- Name: course_to_survey_mapping course_to_survey_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_to_survey_mapping
    ADD CONSTRAINT course_to_survey_mapping_pkey PRIMARY KEY (id);


--
-- Name: course_to_survey_types course_to_survey_types_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_to_survey_types
    ADD CONSTRAINT course_to_survey_types_pkey PRIMARY KEY (id);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: days_of_the_week days_of_the_week_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.days_of_the_week
    ADD CONSTRAINT days_of_the_week_pkey PRIMARY KEY (id);


--
-- Name: exercise_to_media_mapping exercise_to_media_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.exercise_to_media_mapping
    ADD CONSTRAINT exercise_to_media_mapping_pkey PRIMARY KEY (id);


--
-- Name: exercises exercises_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_pkey PRIMARY KEY (id);


--
-- Name: export_to_course_mapping export_to_course_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.export_to_course_mapping
    ADD CONSTRAINT export_to_course_mapping_pkey PRIMARY KEY (id);


--
-- Name: exports exports_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.exports
    ADD CONSTRAINT exports_pkey PRIMARY KEY (id);


--
-- Name: flow_action_types flow_action_types_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.flow_action_types
    ADD CONSTRAINT flow_action_types_pkey PRIMARY KEY (id);


--
-- Name: media_context_types media_context_types_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.media_context_types
    ADD CONSTRAINT media_context_types_pkey PRIMARY KEY (id);


--
-- Name: media media_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_pkey PRIMARY KEY (id);


--
-- Name: message_types message_types_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.message_types
    ADD CONSTRAINT message_types_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: period_type period_type_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.period_type
    ADD CONSTRAINT period_type_pkey PRIMARY KEY (id);


--
-- Name: plan_survey_schedule plan_survey_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_survey_schedule
    ADD CONSTRAINT plan_survey_schedule_pkey PRIMARY KEY (id);


--
-- Name: plan_to_session_mapping plan_to_session_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_to_session_mapping
    ADD CONSTRAINT plan_to_session_mapping_pkey PRIMARY KEY (id);


--
-- Name: plan_to_setting_definition_mapping plan_to_setting_definition_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_to_setting_definition_mapping
    ADD CONSTRAINT plan_to_setting_definition_mapping_pkey PRIMARY KEY (id);


--
-- Name: plan_to_survey_mapping plan_to_survey_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_to_survey_mapping
    ADD CONSTRAINT plan_to_survey_mapping_pkey PRIMARY KEY (id);


--
-- Name: plans plans_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--
-- Name: question_types question_types_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.question_types
    ADD CONSTRAINT question_types_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: resource_type resource_type_name_key; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.resource_type
    ADD CONSTRAINT resource_type_name_key UNIQUE (name);


--
-- Name: resource_type resource_type_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.resource_type
    ADD CONSTRAINT resource_type_pkey PRIMARY KEY (id);


--
-- Name: section_to_question_mapping section_to_question_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.section_to_question_mapping
    ADD CONSTRAINT section_to_question_mapping_pkey PRIMARY KEY (id);


--
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- Name: session_answers session_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_pkey PRIMARY KEY (id);


--
-- Name: session_completion session_completion_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_completion
    ADD CONSTRAINT session_completion_pkey PRIMARY KEY (id);


--
-- Name: session_to_break_mapping session_to_break_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_break_mapping
    ADD CONSTRAINT session_to_break_mapping_pkey PRIMARY KEY (id);


--
-- Name: session_to_exercise_mapping session_to_exercise_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_exercise_mapping
    ADD CONSTRAINT session_to_exercise_mapping_pkey PRIMARY KEY (id);


--
-- Name: session_to_message_mapping session_to_message_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_message_mapping
    ADD CONSTRAINT session_to_message_mapping_pkey PRIMARY KEY (id);


--
-- Name: session_to_survey_mapping session_to_survey_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_survey_mapping
    ADD CONSTRAINT session_to_survey_mapping_pkey PRIMARY KEY (id);


--
-- Name: session_to_survey_types session_to_survey_types_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_survey_types
    ADD CONSTRAINT session_to_survey_types_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: settings_definitions settings_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.settings_definitions
    ADD CONSTRAINT settings_definitions_pkey PRIMARY KEY (id);


--
-- Name: setting_definition_to_setting_mapping settings_definitions_to_settings_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.setting_definition_to_setting_mapping
    ADD CONSTRAINT settings_definitions_to_settings_mapping_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: supported_animations supported_animations_name_key; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.supported_animations
    ADD CONSTRAINT supported_animations_name_key UNIQUE (name);


--
-- Name: supported_animations supported_animations_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.supported_animations
    ADD CONSTRAINT supported_animations_pkey PRIMARY KEY (id);


--
-- Name: supported_settings supported_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.supported_settings
    ADD CONSTRAINT supported_settings_pkey PRIMARY KEY (id);


--
-- Name: survey_actions survey_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.survey_actions
    ADD CONSTRAINT survey_actions_pkey PRIMARY KEY (id);


--
-- Name: survey_flows survey_flows_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.survey_flows
    ADD CONSTRAINT survey_flows_pkey PRIMARY KEY (id);


--
-- Name: survey_to_section_mapping survey_to_section_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.survey_to_section_mapping
    ADD CONSTRAINT survey_to_section_mapping_pkey PRIMARY KEY (id);


--
-- Name: surveys surveys_pkey; Type: CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.surveys
    ADD CONSTRAINT surveys_pkey PRIMARY KEY (id);


--
-- Name: course_answers course_answers_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_answers
    ADD CONSTRAINT course_answers_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_answers course_answers_question_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_answers
    ADD CONSTRAINT course_answers_question_fkey FOREIGN KEY (question) REFERENCES public.questions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_answers course_answers_section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_answers
    ADD CONSTRAINT course_answers_section_fkey FOREIGN KEY (section) REFERENCES public.sections(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_answers course_answers_survey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_answers
    ADD CONSTRAINT course_answers_survey_fkey FOREIGN KEY (survey) REFERENCES public.surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_answers course_answers_survey_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_answers
    ADD CONSTRAINT course_answers_survey_type_fkey FOREIGN KEY (survey_type) REFERENCES public.course_to_survey_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_survey_schedule course_survey_schedule_mapping_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_survey_schedule
    ADD CONSTRAINT course_survey_schedule_mapping_fkey FOREIGN KEY (mapping) REFERENCES public.course_to_survey_mapping(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_survey_schedule course_survey_schedule_period_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_survey_schedule
    ADD CONSTRAINT course_survey_schedule_period_fkey FOREIGN KEY (period) REFERENCES public.period_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_to_plan_mapping course_to_plan_mapping_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_to_plan_mapping
    ADD CONSTRAINT course_to_plan_mapping_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_to_plan_mapping course_to_plan_mapping_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_to_plan_mapping
    ADD CONSTRAINT course_to_plan_mapping_plan_fkey FOREIGN KEY (plan) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_to_survey_mapping course_to_survey_mapping_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_to_survey_mapping
    ADD CONSTRAINT course_to_survey_mapping_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_to_survey_mapping course_to_survey_mapping_survey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_to_survey_mapping
    ADD CONSTRAINT course_to_survey_mapping_survey_fkey FOREIGN KEY (survey) REFERENCES public.surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_to_survey_mapping course_to_survey_mapping_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.course_to_survey_mapping
    ADD CONSTRAINT course_to_survey_mapping_type_fkey FOREIGN KEY (type) REFERENCES public.course_to_survey_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: courses courses_state_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_state_fkey FOREIGN KEY (state) REFERENCES public.course_state_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: exercise_to_media_mapping exercise_to_media_mapping_exercise_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.exercise_to_media_mapping
    ADD CONSTRAINT exercise_to_media_mapping_exercise_fkey FOREIGN KEY (exercise) REFERENCES public.exercises(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: exercise_to_media_mapping exercise_to_media_mapping_media_context_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.exercise_to_media_mapping
    ADD CONSTRAINT exercise_to_media_mapping_media_context_type_fkey FOREIGN KEY (media_context_type) REFERENCES public.media_context_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: exercise_to_media_mapping exercise_to_media_mapping_media_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.exercise_to_media_mapping
    ADD CONSTRAINT exercise_to_media_mapping_media_fkey FOREIGN KEY (media) REFERENCES public.media(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: exercises exercises_description_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_description_resource_fkey FOREIGN KEY (description_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: exercises exercises_instructions_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_instructions_resource_fkey FOREIGN KEY (instructions_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: export_to_course_mapping export_to_course_mapping_export_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.export_to_course_mapping
    ADD CONSTRAINT export_to_course_mapping_export_fkey FOREIGN KEY (export) REFERENCES public.exports(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: media media_internal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_internal_fkey FOREIGN KEY (internal) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: messages messages_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_type_fkey FOREIGN KEY (type) REFERENCES public.message_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plan_survey_schedule plan_survey_schedule_mapping_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_survey_schedule
    ADD CONSTRAINT plan_survey_schedule_mapping_fkey FOREIGN KEY (mapping) REFERENCES public.plan_to_survey_mapping(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plan_survey_schedule plan_survey_schedule_period_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_survey_schedule
    ADD CONSTRAINT plan_survey_schedule_period_fkey FOREIGN KEY (period) REFERENCES public.period_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plan_to_session_mapping plan_to_session_mapping_day_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_to_session_mapping
    ADD CONSTRAINT plan_to_session_mapping_day_fkey FOREIGN KEY (day) REFERENCES public.days_of_the_week(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plan_to_session_mapping plan_to_session_mapping_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_to_session_mapping
    ADD CONSTRAINT plan_to_session_mapping_plan_fkey FOREIGN KEY (plan) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plan_to_session_mapping plan_to_session_mapping_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_to_session_mapping
    ADD CONSTRAINT plan_to_session_mapping_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plan_to_setting_definition_mapping plan_to_setting_definition_mapping_definition_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_to_setting_definition_mapping
    ADD CONSTRAINT plan_to_setting_definition_mapping_definition_fkey FOREIGN KEY (definition) REFERENCES public.settings_definitions(id);


--
-- Name: plan_to_setting_definition_mapping plan_to_setting_definition_mapping_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_to_setting_definition_mapping
    ADD CONSTRAINT plan_to_setting_definition_mapping_plan_fkey FOREIGN KEY (plan) REFERENCES public.plans(id);


--
-- Name: plan_to_survey_mapping plan_to_survey_mapping_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_to_survey_mapping
    ADD CONSTRAINT plan_to_survey_mapping_plan_fkey FOREIGN KEY (plan) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plan_to_survey_mapping plan_to_survey_mapping_survey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_to_survey_mapping
    ADD CONSTRAINT plan_to_survey_mapping_survey_fkey FOREIGN KEY (survey) REFERENCES public.surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plan_to_survey_mapping plan_to_survey_mapping_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plan_to_survey_mapping
    ADD CONSTRAINT plan_to_survey_mapping_type_fkey FOREIGN KEY (type) REFERENCES public.course_to_survey_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plans plans_based_on_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_based_on_fkey FOREIGN KEY (based_on) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plans plans_description_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_description_resource_fkey FOREIGN KEY (description_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: plans plans_diagnostic_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_diagnostic_resource_fkey FOREIGN KEY (diagnostic_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plans plans_instructions_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_instructions_resource_fkey FOREIGN KEY (instructions_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: questions questions_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_type_fkey FOREIGN KEY (type) REFERENCES public.question_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: section_to_question_mapping section_to_question_mapping_question_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.section_to_question_mapping
    ADD CONSTRAINT section_to_question_mapping_question_fkey FOREIGN KEY (question) REFERENCES public.questions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: section_to_question_mapping section_to_question_mapping_section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.section_to_question_mapping
    ADD CONSTRAINT section_to_question_mapping_section_fkey FOREIGN KEY (section) REFERENCES public.sections(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_plan_based_on_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_plan_based_on_fkey FOREIGN KEY (plan_based_on) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_plan_fkey FOREIGN KEY (plan) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_question_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_question_fkey FOREIGN KEY (question) REFERENCES public.questions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_section_fkey FOREIGN KEY (section) REFERENCES public.sections(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_session_based_on_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_session_based_on_fkey FOREIGN KEY (session_based_on) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_survey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_survey_fkey FOREIGN KEY (survey) REFERENCES public.surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_survey_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_survey_type_fkey FOREIGN KEY (survey_type) REFERENCES public.session_to_survey_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_completion session_completion_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_completion
    ADD CONSTRAINT session_completion_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_completion session_completion_last_attempted_exercise_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_completion
    ADD CONSTRAINT session_completion_last_attempted_exercise_fkey FOREIGN KEY (last_attempted_exercise) REFERENCES public.exercises(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_completion session_completion_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_completion
    ADD CONSTRAINT session_completion_plan_fkey FOREIGN KEY (plan) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_completion session_completion_session_based_on_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_completion
    ADD CONSTRAINT session_completion_session_based_on_fkey FOREIGN KEY (session_based_on) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_completion session_completion_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_completion
    ADD CONSTRAINT session_completion_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_break_mapping session_to_break_mapping_entry_animation_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_break_mapping
    ADD CONSTRAINT session_to_break_mapping_entry_animation_fkey FOREIGN KEY (entry_animation) REFERENCES public.supported_animations(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: session_to_break_mapping session_to_break_mapping_exit_animation_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_break_mapping
    ADD CONSTRAINT session_to_break_mapping_exit_animation_fkey FOREIGN KEY (exit_animation) REFERENCES public.supported_animations(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: session_to_break_mapping session_to_break_mapping_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_break_mapping
    ADD CONSTRAINT session_to_break_mapping_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_exercise_mapping session_to_exercise_mapping_entry_animation_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_exercise_mapping
    ADD CONSTRAINT session_to_exercise_mapping_entry_animation_fkey FOREIGN KEY (entry_animation) REFERENCES public.supported_animations(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: session_to_exercise_mapping session_to_exercise_mapping_exercise_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_exercise_mapping
    ADD CONSTRAINT session_to_exercise_mapping_exercise_fkey FOREIGN KEY (exercise) REFERENCES public.exercises(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_exercise_mapping session_to_exercise_mapping_exit_animation_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_exercise_mapping
    ADD CONSTRAINT session_to_exercise_mapping_exit_animation_fkey FOREIGN KEY (exit_animation) REFERENCES public.supported_animations(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: session_to_exercise_mapping session_to_exercise_mapping_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_exercise_mapping
    ADD CONSTRAINT session_to_exercise_mapping_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_message_mapping session_to_message_mapping_message_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_message_mapping
    ADD CONSTRAINT session_to_message_mapping_message_fkey FOREIGN KEY (message) REFERENCES public.messages(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_message_mapping session_to_message_mapping_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_message_mapping
    ADD CONSTRAINT session_to_message_mapping_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_survey_mapping session_to_survey_mapping_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_survey_mapping
    ADD CONSTRAINT session_to_survey_mapping_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_survey_mapping session_to_survey_mapping_survey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_survey_mapping
    ADD CONSTRAINT session_to_survey_mapping_survey_fkey FOREIGN KEY (survey) REFERENCES public.surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_survey_mapping session_to_survey_mapping_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.session_to_survey_mapping
    ADD CONSTRAINT session_to_survey_mapping_type_fkey FOREIGN KEY (type) REFERENCES public.session_to_survey_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sessions sessions_based_on_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_based_on_fkey FOREIGN KEY (based_on) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sessions sessions_description_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_description_resource_fkey FOREIGN KEY (description_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sessions sessions_instructions_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_instructions_resource_fkey FOREIGN KEY (instructions_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: setting_definition_to_setting_mapping settings_definitions_to_settings_mapping_definition_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.setting_definition_to_setting_mapping
    ADD CONSTRAINT settings_definitions_to_settings_mapping_definition_fkey FOREIGN KEY (definition) REFERENCES public.settings_definitions(id);


--
-- Name: setting_definition_to_setting_mapping settings_definitions_to_settings_mapping_setting_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.setting_definition_to_setting_mapping
    ADD CONSTRAINT settings_definitions_to_settings_mapping_setting_fkey FOREIGN KEY (setting) REFERENCES public.settings(id);


--
-- Name: settings settings_setting_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_setting_id_fkey FOREIGN KEY (supported_setting) REFERENCES public.supported_settings(id);


--
-- Name: survey_flows survey_flows_if_question_id_is_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.survey_flows
    ADD CONSTRAINT survey_flows_if_question_id_is_fkey FOREIGN KEY (if_question_id_is) REFERENCES public.questions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_flows survey_flows_if_section_id_is_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.survey_flows
    ADD CONSTRAINT survey_flows_if_section_id_is_fkey FOREIGN KEY (if_section_id_is) REFERENCES public.sections(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_flows survey_flows_if_survey_id_is_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.survey_flows
    ADD CONSTRAINT survey_flows_if_survey_id_is_fkey FOREIGN KEY (if_survey_id_is) REFERENCES public.surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_flows survey_flows_on_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.survey_flows
    ADD CONSTRAINT survey_flows_on_question_id_fkey FOREIGN KEY (on_question_id) REFERENCES public.questions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_flows survey_flows_then_do_action_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.survey_flows
    ADD CONSTRAINT survey_flows_then_do_action_fkey FOREIGN KEY (then_do_action) REFERENCES public.survey_actions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_to_section_mapping survey_to_section_mapping_section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.survey_to_section_mapping
    ADD CONSTRAINT survey_to_section_mapping_section_fkey FOREIGN KEY (section) REFERENCES public.sections(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_to_section_mapping survey_to_section_mapping_survey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: digitallabsadmin
--

ALTER TABLE ONLY public.survey_to_section_mapping
    ADD CONSTRAINT survey_to_section_mapping_survey_fkey FOREIGN KEY (survey) REFERENCES public.surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

