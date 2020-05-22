--
-- PostgreSQL database dump
--

-- Dumped from database version 10.4
-- Dumped by pg_dump version 10.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

			
--		
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 		
--		
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;		
--		
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 		
--		
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: base64_resources; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.base64_resources (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    mime_type text,
    data text
);


ALTER TABLE public.base64_resources OWNER TO coops;

--
-- Name: base64_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: coops
--

CREATE SEQUENCE public.base64_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.base64_resources_id_seq OWNER TO coops;

--
-- Name: base64_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: coops
--

ALTER SEQUENCE public.base64_resources_id_seq OWNED BY public.base64_resources.id;


--
-- Name: course_answers; Type: TABLE; Schema: public; Owner: coops
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


ALTER TABLE public.course_answers OWNER TO coops;

--
-- Name: course_state_types; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.course_state_types (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.course_state_types OWNER TO coops;

--
-- Name: course_survey_schedule; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.course_survey_schedule (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    every integer,
    period integer,
    mapping text,
    from_date date DEFAULT ('now'::text)::date
);


ALTER TABLE public.course_survey_schedule OWNER TO coops;

--
-- Name: course_to_plan_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.course_to_plan_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    course text,
    plan text,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()),
    completed timestamp without time zone
);


ALTER TABLE public.course_to_plan_mapping OWNER TO coops;

--
-- Name: course_to_survey_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.course_to_survey_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    course text,
    survey text,
    type integer
);


ALTER TABLE public.course_to_survey_mapping OWNER TO coops;

--
-- Name: course_to_survey_types; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.course_to_survey_types (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.course_to_survey_types OWNER TO coops;

--
-- Name: courses; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.courses (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    state integer DEFAULT 1,
    version bigint DEFAULT '0'::bigint,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()),
    data_version bigint DEFAULT '0'::bigint
);


ALTER TABLE public.courses OWNER TO coops;

--
-- Name: days_of_the_week; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.days_of_the_week (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.days_of_the_week OWNER TO coops;

--
-- Name: deployment_state_types; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.deployment_state_types (
    id integer DEFAULT 0 NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.deployment_state_types OWNER TO coops;

--
-- Name: deployments; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.deployments (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    state integer DEFAULT 0,
    course_id text,
    created timestamp without time zone DEFAULT timezone('utc'::text, now()),
    token text
);


ALTER TABLE public.deployments OWNER TO coops;

--
-- Name: exercise_to_media_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.exercise_to_media_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    exercise text,
    media text,
    media_context_type integer
);


ALTER TABLE public.exercise_to_media_mapping OWNER TO coops;

--
-- Name: exercises; Type: TABLE; Schema: public; Owner: coops
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


ALTER TABLE public.exercises OWNER TO coops;

--
-- Name: flow_action_types; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.flow_action_types (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.flow_action_types OWNER TO coops;

--
-- Name: media; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.media (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    url text,
    mime_type text,
    internal text
);


ALTER TABLE public.media OWNER TO coops;

--
-- Name: media_context_types; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.media_context_types (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.media_context_types OWNER TO coops;

--
-- Name: message_types; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.message_types (
    id integer NOT NULL,
    name text,
    description text
);


ALTER TABLE public.message_types OWNER TO coops;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.messages (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    content text,
    type integer
);


ALTER TABLE public.messages OWNER TO coops;

--
-- Name: organisation_scopes; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.organisation_scopes (
    id integer DEFAULT 0 NOT NULL,
    name text
);


ALTER TABLE public.organisation_scopes OWNER TO coops;

--
-- Name: organisation_to_course_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.organisation_to_course_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    organisation text,
    course text
);


ALTER TABLE public.organisation_to_course_mapping OWNER TO coops;

--
-- Name: organisation_to_plan_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.organisation_to_plan_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    organisation text,
    plan text
);


ALTER TABLE public.organisation_to_plan_mapping OWNER TO coops;

--
-- Name: organisations; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.organisations (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    name text
);


ALTER TABLE public.organisations OWNER TO coops;

--
-- Name: period_type; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.period_type (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.period_type OWNER TO coops;

--
-- Name: plan_to_session_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.plan_to_session_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    plan text,
    session text,
    day integer,
    "order" integer
);


ALTER TABLE public.plan_to_session_mapping OWNER TO coops;

--
-- Name: plan_to_setting_definition_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.plan_to_setting_definition_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    plan text,
    definition text
);


ALTER TABLE public.plan_to_setting_definition_mapping OWNER TO coops;

--
-- Name: plans; Type: TABLE; Schema: public; Owner: coops
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


ALTER TABLE public.plans OWNER TO coops;

--
-- Name: publish_states; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.publish_states (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.publish_states OWNER TO coops;

--
-- Name: published; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.published (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    id_of_published_entity text NOT NULL,
    state integer
);


ALTER TABLE public.published OWNER TO coops;

--
-- Name: question_types; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.question_types (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.question_types OWNER TO coops;

--
-- Name: questions; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.questions (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    type integer,
    text text,
    json_array_string_choices text
);


ALTER TABLE public.questions OWNER TO coops;

--
-- Name: resource_type; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.resource_type (
    id integer NOT NULL,
    name text NOT NULL,
    mime_type text NOT NULL
);


ALTER TABLE public.resource_type OWNER TO coops;

--
-- Name: resource_type_id_seq; Type: SEQUENCE; Schema: public; Owner: coops
--

CREATE SEQUENCE public.resource_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.resource_type_id_seq OWNER TO coops;

--
-- Name: resource_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: coops
--

ALTER SEQUENCE public.resource_type_id_seq OWNED BY public.resource_type.id;


--
-- Name: section_to_question_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.section_to_question_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    section text,
    question text
);


ALTER TABLE public.section_to_question_mapping OWNER TO coops;

--
-- Name: sections; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.sections (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    title text,
    intro_message text
);


ALTER TABLE public.sections OWNER TO coops;

--
-- Name: session_answers; Type: TABLE; Schema: public; Owner: coops
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


ALTER TABLE public.session_answers OWNER TO coops;

--
-- Name: session_completion; Type: TABLE; Schema: public; Owner: coops
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


ALTER TABLE public.session_completion OWNER TO coops;

--
-- Name: session_to_break_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.session_to_break_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    session text,
    break_s integer,
    "order" integer
);


ALTER TABLE public.session_to_break_mapping OWNER TO coops;

--
-- Name: session_to_exercise_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.session_to_exercise_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    session text,
    exercise text,
    reps integer,
    "order" integer
);


ALTER TABLE public.session_to_exercise_mapping OWNER TO coops;

--
-- Name: session_to_message_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.session_to_message_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    session text,
    message text,
    "order" integer,
    substitution text,
    duration_s integer DEFAULT 10
);


ALTER TABLE public.session_to_message_mapping OWNER TO coops;

--
-- Name: session_to_survey_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.session_to_survey_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    session text,
    survey text,
    type integer
);


ALTER TABLE public.session_to_survey_mapping OWNER TO coops;

--
-- Name: session_to_survey_types; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.session_to_survey_types (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.session_to_survey_types OWNER TO coops;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: coops
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


ALTER TABLE public.sessions OWNER TO coops;

--
-- Name: setting_definition_to_setting_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.setting_definition_to_setting_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    definition text,
    setting text
);


ALTER TABLE public.setting_definition_to_setting_mapping OWNER TO coops;

--
-- Name: settings; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.settings (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    supported_setting text,
    value text NOT NULL
);


ALTER TABLE public.settings OWNER TO coops;

--
-- Name: settings_definitions; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.settings_definitions (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.settings_definitions OWNER TO coops;

--
-- Name: share_states; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.share_states (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.share_states OWNER TO coops;

--
-- Name: shared; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.shared (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    id_of_shared_entity text NOT NULL,
    state integer
);


ALTER TABLE public.shared OWNER TO coops;

--
-- Name: supported_settings; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.supported_settings (
    id text NOT NULL,
    friendly_name text NOT NULL,
    type text NOT NULL,
    "default" text
);


ALTER TABLE public.supported_settings OWNER TO coops;

--
-- Name: survey_actions; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.survey_actions (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.survey_actions OWNER TO coops;

--
-- Name: survey_flows; Type: TABLE; Schema: public; Owner: coops
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


ALTER TABLE public.survey_flows OWNER TO coops;

--
-- Name: survey_to_section_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.survey_to_section_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    survey text,
    section text
);


ALTER TABLE public.survey_to_section_mapping OWNER TO coops;

--
-- Name: surveys; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.surveys (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    title text,
    intro_message text,
    exit_message text
);


ALTER TABLE public.surveys OWNER TO coops;

--
-- Name: user_to_course_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.user_to_course_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    "user" text,
    course text
);


ALTER TABLE public.user_to_course_mapping OWNER TO coops;

--
-- Name: user_to_organisation_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.user_to_organisation_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    "user" text,
    organisation text,
    scope integer
);


ALTER TABLE public.user_to_organisation_mapping OWNER TO coops;

--
-- Name: user_to_plan_mapping; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.user_to_plan_mapping (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    "user" text,
    plan text
);


ALTER TABLE public.user_to_plan_mapping OWNER TO coops;

--
-- Name: users; Type: TABLE; Schema: public; Owner: coops
--

CREATE TABLE public.users (
    id text DEFAULT public.uuid_generate_v4() NOT NULL,
    external_id text,
    created timestamp without time zone DEFAULT timezone('utc'::text, now())
);


ALTER TABLE public.users OWNER TO coops;

--
-- Name: resource_type id; Type: DEFAULT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.resource_type ALTER COLUMN id SET DEFAULT nextval('public.resource_type_id_seq'::regclass);


--
-- Name: base64_resources base64_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.base64_resources
    ADD CONSTRAINT base64_resources_pkey PRIMARY KEY (id);


--
-- Name: course_answers course_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_answers
    ADD CONSTRAINT course_answers_pkey PRIMARY KEY (id);


--
-- Name: course_state_types course_state_types_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_state_types
    ADD CONSTRAINT course_state_types_pkey PRIMARY KEY (id);


--
-- Name: course_survey_schedule course_survey_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_survey_schedule
    ADD CONSTRAINT course_survey_schedule_pkey PRIMARY KEY (id);


--
-- Name: course_to_plan_mapping course_to_plan_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_to_plan_mapping
    ADD CONSTRAINT course_to_plan_mapping_pkey PRIMARY KEY (id);


--
-- Name: course_to_survey_mapping course_to_survey_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_to_survey_mapping
    ADD CONSTRAINT course_to_survey_mapping_pkey PRIMARY KEY (id);


--
-- Name: course_to_survey_types course_to_survey_types_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_to_survey_types
    ADD CONSTRAINT course_to_survey_types_pkey PRIMARY KEY (id);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: days_of_the_week days_of_the_week_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.days_of_the_week
    ADD CONSTRAINT days_of_the_week_pkey PRIMARY KEY (id);


--
-- Name: deployment_state_types deployment_state_types_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.deployment_state_types
    ADD CONSTRAINT deployment_state_types_pkey PRIMARY KEY (id);


--
-- Name: deployments deployments_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT deployments_pkey PRIMARY KEY (id);


--
-- Name: exercise_to_media_mapping exercise_to_media_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.exercise_to_media_mapping
    ADD CONSTRAINT exercise_to_media_mapping_pkey PRIMARY KEY (id);


--
-- Name: exercises exercises_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_pkey PRIMARY KEY (id);


--
-- Name: flow_action_types flow_action_types_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.flow_action_types
    ADD CONSTRAINT flow_action_types_pkey PRIMARY KEY (id);


--
-- Name: media_context_types media_context_types_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.media_context_types
    ADD CONSTRAINT media_context_types_pkey PRIMARY KEY (id);


--
-- Name: media media_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_pkey PRIMARY KEY (id);


--
-- Name: message_types message_types_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.message_types
    ADD CONSTRAINT message_types_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: organisation_scopes organisation_scopes_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.organisation_scopes
    ADD CONSTRAINT organisation_scopes_pkey PRIMARY KEY (id);


--
-- Name: organisation_to_course_mapping organisation_to_course_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.organisation_to_course_mapping
    ADD CONSTRAINT organisation_to_course_mapping_pkey PRIMARY KEY (id);


--
-- Name: organisation_to_plan_mapping organisation_to_plan_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.organisation_to_plan_mapping
    ADD CONSTRAINT organisation_to_plan_mapping_pkey PRIMARY KEY (id);


--
-- Name: organisations organisations_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: period_type period_type_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.period_type
    ADD CONSTRAINT period_type_pkey PRIMARY KEY (id);


--
-- Name: plan_to_session_mapping plan_to_session_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.plan_to_session_mapping
    ADD CONSTRAINT plan_to_session_mapping_pkey PRIMARY KEY (id);


--
-- Name: plan_to_setting_definition_mapping plan_to_setting_definition_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.plan_to_setting_definition_mapping
    ADD CONSTRAINT plan_to_setting_definition_mapping_pkey PRIMARY KEY (id);


--
-- Name: plans plans_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--
-- Name: publish_states publish_states_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.publish_states
    ADD CONSTRAINT publish_states_pkey PRIMARY KEY (id);


--
-- Name: published published_id_of_published_entity_key; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.published
    ADD CONSTRAINT published_id_of_published_entity_key UNIQUE (id_of_published_entity);


--
-- Name: published published_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.published
    ADD CONSTRAINT published_pkey PRIMARY KEY (id);


--
-- Name: question_types question_types_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.question_types
    ADD CONSTRAINT question_types_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: resource_type resource_type_name_key; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.resource_type
    ADD CONSTRAINT resource_type_name_key UNIQUE (name);


--
-- Name: resource_type resource_type_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.resource_type
    ADD CONSTRAINT resource_type_pkey PRIMARY KEY (id);


--
-- Name: section_to_question_mapping section_to_question_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.section_to_question_mapping
    ADD CONSTRAINT section_to_question_mapping_pkey PRIMARY KEY (id);


--
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- Name: session_answers session_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_pkey PRIMARY KEY (id);


--
-- Name: session_completion session_completion_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_completion
    ADD CONSTRAINT session_completion_pkey PRIMARY KEY (id);


--
-- Name: session_to_break_mapping session_to_break_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_to_break_mapping
    ADD CONSTRAINT session_to_break_mapping_pkey PRIMARY KEY (id);


--
-- Name: session_to_exercise_mapping session_to_exercise_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_to_exercise_mapping
    ADD CONSTRAINT session_to_exercise_mapping_pkey PRIMARY KEY (id);


--
-- Name: session_to_message_mapping session_to_message_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_to_message_mapping
    ADD CONSTRAINT session_to_message_mapping_pkey PRIMARY KEY (id);


--
-- Name: session_to_survey_mapping session_to_survey_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_to_survey_mapping
    ADD CONSTRAINT session_to_survey_mapping_pkey PRIMARY KEY (id);


--
-- Name: session_to_survey_types session_to_survey_types_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_to_survey_types
    ADD CONSTRAINT session_to_survey_types_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: settings_definitions settings_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.settings_definitions
    ADD CONSTRAINT settings_definitions_pkey PRIMARY KEY (id);


--
-- Name: setting_definition_to_setting_mapping settings_definitions_to_settings_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.setting_definition_to_setting_mapping
    ADD CONSTRAINT settings_definitions_to_settings_mapping_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: share_states share_states_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.share_states
    ADD CONSTRAINT share_states_pkey PRIMARY KEY (id);


--
-- Name: shared shared_id_of_shared_entity_key; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.shared
    ADD CONSTRAINT shared_id_of_shared_entity_key UNIQUE (id_of_shared_entity);


--
-- Name: shared shared_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.shared
    ADD CONSTRAINT shared_pkey PRIMARY KEY (id);


--
-- Name: supported_settings supported_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.supported_settings
    ADD CONSTRAINT supported_settings_pkey PRIMARY KEY (id);


--
-- Name: survey_actions survey_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.survey_actions
    ADD CONSTRAINT survey_actions_pkey PRIMARY KEY (id);


--
-- Name: survey_flows survey_flows_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.survey_flows
    ADD CONSTRAINT survey_flows_pkey PRIMARY KEY (id);


--
-- Name: survey_to_section_mapping survey_to_section_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.survey_to_section_mapping
    ADD CONSTRAINT survey_to_section_mapping_pkey PRIMARY KEY (id);


--
-- Name: surveys surveys_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.surveys
    ADD CONSTRAINT surveys_pkey PRIMARY KEY (id);


--
-- Name: user_to_course_mapping user_to_course_mappincg_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.user_to_course_mapping
    ADD CONSTRAINT user_to_course_mappincg_pkey PRIMARY KEY (id);


--
-- Name: user_to_organisation_mapping user_to_organisation_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.user_to_organisation_mapping
    ADD CONSTRAINT user_to_organisation_mapping_pkey PRIMARY KEY (id);


--
-- Name: user_to_plan_mapping user_to_plan_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.user_to_plan_mapping
    ADD CONSTRAINT user_to_plan_mapping_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: course_answers course_answers_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_answers
    ADD CONSTRAINT course_answers_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_answers course_answers_question_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_answers
    ADD CONSTRAINT course_answers_question_fkey FOREIGN KEY (question) REFERENCES public.questions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_answers course_answers_section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_answers
    ADD CONSTRAINT course_answers_section_fkey FOREIGN KEY (section) REFERENCES public.sections(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_answers course_answers_survey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_answers
    ADD CONSTRAINT course_answers_survey_fkey FOREIGN KEY (survey) REFERENCES public.surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_answers course_answers_survey_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_answers
    ADD CONSTRAINT course_answers_survey_type_fkey FOREIGN KEY (survey_type) REFERENCES public.course_to_survey_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_survey_schedule course_survey_schedule_mapping_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_survey_schedule
    ADD CONSTRAINT course_survey_schedule_mapping_fkey FOREIGN KEY (mapping) REFERENCES public.course_to_survey_mapping(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_survey_schedule course_survey_schedule_period_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_survey_schedule
    ADD CONSTRAINT course_survey_schedule_period_fkey FOREIGN KEY (period) REFERENCES public.period_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_to_plan_mapping course_to_plan_mapping_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_to_plan_mapping
    ADD CONSTRAINT course_to_plan_mapping_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_to_plan_mapping course_to_plan_mapping_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_to_plan_mapping
    ADD CONSTRAINT course_to_plan_mapping_plan_fkey FOREIGN KEY (plan) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_to_survey_mapping course_to_survey_mapping_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_to_survey_mapping
    ADD CONSTRAINT course_to_survey_mapping_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_to_survey_mapping course_to_survey_mapping_survey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_to_survey_mapping
    ADD CONSTRAINT course_to_survey_mapping_survey_fkey FOREIGN KEY (survey) REFERENCES public.surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_to_survey_mapping course_to_survey_mapping_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.course_to_survey_mapping
    ADD CONSTRAINT course_to_survey_mapping_type_fkey FOREIGN KEY (type) REFERENCES public.course_to_survey_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: courses courses_state_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_state_fkey FOREIGN KEY (state) REFERENCES public.course_state_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: deployments deployments_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT deployments_course_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: deployments deployments_state_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.deployments
    ADD CONSTRAINT deployments_state_fkey FOREIGN KEY (state) REFERENCES public.deployment_state_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: exercise_to_media_mapping exercise_to_media_mapping_exercise_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.exercise_to_media_mapping
    ADD CONSTRAINT exercise_to_media_mapping_exercise_fkey FOREIGN KEY (exercise) REFERENCES public.exercises(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: exercise_to_media_mapping exercise_to_media_mapping_media_context_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.exercise_to_media_mapping
    ADD CONSTRAINT exercise_to_media_mapping_media_context_type_fkey FOREIGN KEY (media_context_type) REFERENCES public.media_context_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: exercise_to_media_mapping exercise_to_media_mapping_media_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.exercise_to_media_mapping
    ADD CONSTRAINT exercise_to_media_mapping_media_fkey FOREIGN KEY (media) REFERENCES public.media(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: exercises exercises_description_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_description_resource_fkey FOREIGN KEY (description_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: exercises exercises_instructions_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_instructions_resource_fkey FOREIGN KEY (instructions_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: media media_internal_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_internal_fkey FOREIGN KEY (internal) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: messages messages_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_type_fkey FOREIGN KEY (type) REFERENCES public.message_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: organisation_to_course_mapping organisation_to_course_mapping_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.organisation_to_course_mapping
    ADD CONSTRAINT organisation_to_course_mapping_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: organisation_to_course_mapping organisation_to_course_mapping_organisation_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.organisation_to_course_mapping
    ADD CONSTRAINT organisation_to_course_mapping_organisation_fkey FOREIGN KEY (organisation) REFERENCES public.organisations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: organisation_to_plan_mapping organisation_to_plan_mapping_organisation_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.organisation_to_plan_mapping
    ADD CONSTRAINT organisation_to_plan_mapping_organisation_fkey FOREIGN KEY (organisation) REFERENCES public.organisations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: organisation_to_plan_mapping organisation_to_plan_mapping_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.organisation_to_plan_mapping
    ADD CONSTRAINT organisation_to_plan_mapping_plan_fkey FOREIGN KEY (plan) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plan_to_session_mapping plan_to_session_mapping_day_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.plan_to_session_mapping
    ADD CONSTRAINT plan_to_session_mapping_day_fkey FOREIGN KEY (day) REFERENCES public.days_of_the_week(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plan_to_session_mapping plan_to_session_mapping_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.plan_to_session_mapping
    ADD CONSTRAINT plan_to_session_mapping_plan_fkey FOREIGN KEY (plan) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plan_to_session_mapping plan_to_session_mapping_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.plan_to_session_mapping
    ADD CONSTRAINT plan_to_session_mapping_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plan_to_setting_definition_mapping plan_to_setting_definition_mapping_definition_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.plan_to_setting_definition_mapping
    ADD CONSTRAINT plan_to_setting_definition_mapping_definition_fkey FOREIGN KEY (definition) REFERENCES public.settings_definitions(id);


--
-- Name: plan_to_setting_definition_mapping plan_to_setting_definition_mapping_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.plan_to_setting_definition_mapping
    ADD CONSTRAINT plan_to_setting_definition_mapping_plan_fkey FOREIGN KEY (plan) REFERENCES public.plans(id);


--
-- Name: plans plans_based_on_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_based_on_fkey FOREIGN KEY (based_on) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plans plans_description_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_description_resource_fkey FOREIGN KEY (description_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: plans plans_diagnostic_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_diagnostic_resource_fkey FOREIGN KEY (diagnostic_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: plans plans_instructions_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.plans
    ADD CONSTRAINT plans_instructions_resource_fkey FOREIGN KEY (instructions_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: published published_state_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.published
    ADD CONSTRAINT published_state_fkey FOREIGN KEY (state) REFERENCES public.publish_states(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: questions questions_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_type_fkey FOREIGN KEY (type) REFERENCES public.question_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: section_to_question_mapping section_to_question_mapping_question_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.section_to_question_mapping
    ADD CONSTRAINT section_to_question_mapping_question_fkey FOREIGN KEY (question) REFERENCES public.questions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: section_to_question_mapping section_to_question_mapping_section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.section_to_question_mapping
    ADD CONSTRAINT section_to_question_mapping_section_fkey FOREIGN KEY (section) REFERENCES public.sections(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_plan_based_on_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_plan_based_on_fkey FOREIGN KEY (plan_based_on) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_plan_fkey FOREIGN KEY (plan) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_question_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_question_fkey FOREIGN KEY (question) REFERENCES public.questions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_section_fkey FOREIGN KEY (section) REFERENCES public.sections(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_session_based_on_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_session_based_on_fkey FOREIGN KEY (session_based_on) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_survey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_survey_fkey FOREIGN KEY (survey) REFERENCES public.surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_answers session_answers_survey_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_answers
    ADD CONSTRAINT session_answers_survey_type_fkey FOREIGN KEY (survey_type) REFERENCES public.session_to_survey_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_completion session_completion_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_completion
    ADD CONSTRAINT session_completion_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_completion session_completion_last_attempted_exercise_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_completion
    ADD CONSTRAINT session_completion_last_attempted_exercise_fkey FOREIGN KEY (last_attempted_exercise) REFERENCES public.exercises(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_completion session_completion_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_completion
    ADD CONSTRAINT session_completion_plan_fkey FOREIGN KEY (plan) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_completion session_completion_session_based_on_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_completion
    ADD CONSTRAINT session_completion_session_based_on_fkey FOREIGN KEY (session_based_on) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_completion session_completion_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_completion
    ADD CONSTRAINT session_completion_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_break_mapping session_to_break_mapping_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_to_break_mapping
    ADD CONSTRAINT session_to_break_mapping_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_exercise_mapping session_to_exercise_mapping_exercise_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_to_exercise_mapping
    ADD CONSTRAINT session_to_exercise_mapping_exercise_fkey FOREIGN KEY (exercise) REFERENCES public.exercises(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_exercise_mapping session_to_exercise_mapping_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_to_exercise_mapping
    ADD CONSTRAINT session_to_exercise_mapping_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_message_mapping session_to_message_mapping_message_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_to_message_mapping
    ADD CONSTRAINT session_to_message_mapping_message_fkey FOREIGN KEY (message) REFERENCES public.messages(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_message_mapping session_to_message_mapping_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_to_message_mapping
    ADD CONSTRAINT session_to_message_mapping_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_survey_mapping session_to_survey_mapping_session_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_to_survey_mapping
    ADD CONSTRAINT session_to_survey_mapping_session_fkey FOREIGN KEY (session) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_survey_mapping session_to_survey_mapping_survey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_to_survey_mapping
    ADD CONSTRAINT session_to_survey_mapping_survey_fkey FOREIGN KEY (survey) REFERENCES public.surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_to_survey_mapping session_to_survey_mapping_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.session_to_survey_mapping
    ADD CONSTRAINT session_to_survey_mapping_type_fkey FOREIGN KEY (type) REFERENCES public.session_to_survey_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sessions sessions_based_on_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_based_on_fkey FOREIGN KEY (based_on) REFERENCES public.sessions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: sessions sessions_description_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_description_resource_fkey FOREIGN KEY (description_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: sessions sessions_instructions_resource_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_instructions_resource_fkey FOREIGN KEY (instructions_resource) REFERENCES public.base64_resources(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: setting_definition_to_setting_mapping settings_definitions_to_settings_mapping_definition_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.setting_definition_to_setting_mapping
    ADD CONSTRAINT settings_definitions_to_settings_mapping_definition_fkey FOREIGN KEY (definition) REFERENCES public.settings_definitions(id);


--
-- Name: setting_definition_to_setting_mapping settings_definitions_to_settings_mapping_setting_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.setting_definition_to_setting_mapping
    ADD CONSTRAINT settings_definitions_to_settings_mapping_setting_fkey FOREIGN KEY (setting) REFERENCES public.settings(id);


--
-- Name: settings settings_setting_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_setting_id_fkey FOREIGN KEY (supported_setting) REFERENCES public.supported_settings(id);


--
-- Name: shared shared_state_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.shared
    ADD CONSTRAINT shared_state_fkey FOREIGN KEY (state) REFERENCES public.share_states(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_flows survey_flows_if_question_id_is_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.survey_flows
    ADD CONSTRAINT survey_flows_if_question_id_is_fkey FOREIGN KEY (if_question_id_is) REFERENCES public.questions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_flows survey_flows_if_section_id_is_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.survey_flows
    ADD CONSTRAINT survey_flows_if_section_id_is_fkey FOREIGN KEY (if_section_id_is) REFERENCES public.sections(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_flows survey_flows_if_survey_id_is_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.survey_flows
    ADD CONSTRAINT survey_flows_if_survey_id_is_fkey FOREIGN KEY (if_survey_id_is) REFERENCES public.surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_flows survey_flows_on_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.survey_flows
    ADD CONSTRAINT survey_flows_on_question_id_fkey FOREIGN KEY (on_question_id) REFERENCES public.questions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_flows survey_flows_then_do_action_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.survey_flows
    ADD CONSTRAINT survey_flows_then_do_action_fkey FOREIGN KEY (then_do_action) REFERENCES public.survey_actions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_to_section_mapping survey_to_section_mapping_section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.survey_to_section_mapping
    ADD CONSTRAINT survey_to_section_mapping_section_fkey FOREIGN KEY (section) REFERENCES public.sections(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_to_section_mapping survey_to_section_mapping_survey_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.survey_to_section_mapping
    ADD CONSTRAINT survey_to_section_mapping_survey_fkey FOREIGN KEY (survey) REFERENCES public.surveys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_to_course_mapping user_to_course_mapping_course_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.user_to_course_mapping
    ADD CONSTRAINT user_to_course_mapping_course_fkey FOREIGN KEY (course) REFERENCES public.courses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_to_course_mapping user_to_course_mapping_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.user_to_course_mapping
    ADD CONSTRAINT user_to_course_mapping_user_fkey FOREIGN KEY ("user") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_to_organisation_mapping user_to_organisation_mapping_organisation_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.user_to_organisation_mapping
    ADD CONSTRAINT user_to_organisation_mapping_organisation_fkey FOREIGN KEY (organisation) REFERENCES public.organisations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_to_organisation_mapping user_to_organisation_mapping_scope_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.user_to_organisation_mapping
    ADD CONSTRAINT user_to_organisation_mapping_scope_fkey FOREIGN KEY (scope) REFERENCES public.organisation_scopes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_to_organisation_mapping user_to_organisation_mapping_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.user_to_organisation_mapping
    ADD CONSTRAINT user_to_organisation_mapping_user_fkey FOREIGN KEY ("user") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_to_plan_mapping user_to_plan_mapping_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.user_to_plan_mapping
    ADD CONSTRAINT user_to_plan_mapping_plan_fkey FOREIGN KEY (plan) REFERENCES public.plans(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_to_plan_mapping user_to_plan_mapping_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: coops
--

ALTER TABLE ONLY public.user_to_plan_mapping
    ADD CONSTRAINT user_to_plan_mapping_user_fkey FOREIGN KEY ("user") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

