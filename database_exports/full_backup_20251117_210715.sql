--
-- PostgreSQL database dump
--

\restrict ExBd0VgheDkfwlNZdkmjZUA1O9NkSHbQesOyIJzZafR5rq0K5fWc67lQmi3PCSb

-- Dumped from database version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

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

ALTER TABLE IF EXISTS ONLY public.bids DROP CONSTRAINT IF EXISTS bids_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.bids DROP CONSTRAINT IF EXISTS bids_painting_id_fkey;
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS update_paintings_updated_at ON public.paintings;
DROP TRIGGER IF EXISTS update_auction_settings_updated_at ON public.auction_settings;
DROP INDEX IF EXISTS public.idx_users_mobile;
DROP INDEX IF EXISTS public.idx_paintings_status;
DROP INDEX IF EXISTS public.idx_bids_user_id;
DROP INDEX IF EXISTS public.idx_bids_painting_id;
DROP INDEX IF EXISTS public.idx_bids_amount;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_mobile_key;
ALTER TABLE IF EXISTS ONLY public.paintings DROP CONSTRAINT IF EXISTS paintings_qr_code_data_key;
ALTER TABLE IF EXISTS ONLY public.paintings DROP CONSTRAINT IF EXISTS paintings_pkey;
ALTER TABLE IF EXISTS ONLY public.bids DROP CONSTRAINT IF EXISTS bids_pkey;
ALTER TABLE IF EXISTS ONLY public.auction_settings DROP CONSTRAINT IF EXISTS auction_settings_pkey;
ALTER TABLE IF EXISTS ONLY public.admins DROP CONSTRAINT IF EXISTS admins_username_key;
ALTER TABLE IF EXISTS ONLY public.admins DROP CONSTRAINT IF EXISTS admins_pkey;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.paintings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.bids ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.auction_settings ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.admins ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public.users;
DROP VIEW IF EXISTS public.user_bid_rankings;
DROP SEQUENCE IF EXISTS public.paintings_id_seq;
DROP VIEW IF EXISTS public.painting_current_bids;
DROP TABLE IF EXISTS public.paintings;
DROP SEQUENCE IF EXISTS public.bids_id_seq;
DROP TABLE IF EXISTS public.bids;
DROP SEQUENCE IF EXISTS public.auction_settings_id_seq;
DROP TABLE IF EXISTS public.auction_settings;
DROP SEQUENCE IF EXISTS public.admins_id_seq;
DROP TABLE IF EXISTS public.admins;
DROP FUNCTION IF EXISTS public.update_updated_at_column();
--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password_hash character varying(255) NOT NULL,
    email character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp without time zone
);


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- Name: auction_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auction_settings (
    id integer NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: auction_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auction_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auction_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auction_settings_id_seq OWNED BY public.auction_settings.id;


--
-- Name: bids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bids (
    id integer NOT NULL,
    painting_id integer NOT NULL,
    user_id integer NOT NULL,
    bid_amount numeric(10,2) NOT NULL,
    bid_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'active'::character varying,
    CONSTRAINT bid_amount_positive CHECK ((bid_amount > (0)::numeric)),
    CONSTRAINT bids_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'cancelled'::character varying, 'won'::character varying])::text[])))
);


--
-- Name: bids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bids_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bids_id_seq OWNED BY public.bids.id;


--
-- Name: paintings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paintings (
    id integer NOT NULL,
    artist_name character varying(200) NOT NULL,
    painting_name character varying(200) NOT NULL,
    image_url text,
    base_price numeric(10,2) NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying,
    qr_code_data text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT paintings_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'inactive'::character varying, 'sold'::character varying])::text[])))
);


--
-- Name: painting_current_bids; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.painting_current_bids AS
 SELECT p.id AS painting_id,
    p.artist_name,
    p.painting_name,
    p.base_price,
    p.image_url,
    p.status,
    COALESCE(max(b.bid_amount), p.base_price) AS current_price,
    count(b.id) AS total_bids
   FROM (public.paintings p
     LEFT JOIN public.bids b ON (((p.id = b.painting_id) AND ((b.status)::text = 'active'::text))))
  GROUP BY p.id, p.artist_name, p.painting_name, p.base_price, p.image_url, p.status;


--
-- Name: paintings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.paintings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: paintings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.paintings_id_seq OWNED BY public.paintings.id;


--
-- Name: user_bid_rankings; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.user_bid_rankings AS
 SELECT id AS bid_id,
    painting_id,
    user_id,
    bid_amount,
    bid_time,
    rank() OVER (PARTITION BY painting_id ORDER BY bid_amount DESC, bid_time) AS rank
   FROM public.bids b
  WHERE ((status)::text = 'active'::text);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    mobile character varying(15) NOT NULL,
    password_hash character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- Name: auction_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auction_settings ALTER COLUMN id SET DEFAULT nextval('public.auction_settings_id_seq'::regclass);


--
-- Name: bids id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bids ALTER COLUMN id SET DEFAULT nextval('public.bids_id_seq'::regclass);


--
-- Name: paintings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paintings ALTER COLUMN id SET DEFAULT nextval('public.paintings_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admins (id, username, password_hash, email, created_at, last_login) FROM stdin;
1	admin	$2b$10$aDsCMx/juZ.OVbG5Lqx1Ae0LdUYJtCjMBrgh52lX.jJBIsxPAfy42	admin@college.edu	2025-11-17 14:04:50.539549	2025-11-17 21:02:44.803127
\.


--
-- Data for Name: auction_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auction_settings (id, start_date, end_date, is_active, created_at, updated_at) FROM stdin;
1	2025-11-17 13:33:28.429631	2025-12-17 13:33:28.429631	t	2025-11-17 13:33:28.429631	2025-11-17 13:33:28.429631
2	2025-11-17 14:04:50.540825	2025-12-17 14:04:50.540825	t	2025-11-17 14:04:50.540825	2025-11-17 14:04:50.540825
\.


--
-- Data for Name: bids; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bids (id, painting_id, user_id, bid_amount, bid_time, status) FROM stdin;
1	1	2	1111.00	2025-11-17 14:59:58.855201	active
2	1	1	2001.00	2025-11-17 15:05:29.7308	active
3	2	2	1105.00	2025-11-17 15:47:00.455851	active
4	1	2	2509.00	2025-11-17 16:34:08.693299	active
5	1	2	3010.00	2025-11-17 16:34:13.73771	active
6	1	2	3511.00	2025-11-17 16:34:20.793414	active
7	1	2	4012.00	2025-11-17 16:34:33.577042	active
8	1	2	4514.00	2025-11-17 16:38:49.341866	active
9	2	2	3106.00	2025-11-17 16:49:52.009042	active
10	2	2	4607.00	2025-11-17 16:50:04.863426	active
11	2	2	5108.00	2025-11-17 16:50:10.136136	active
12	1	2	5515.00	2025-11-17 16:51:26.101885	active
13	1	2	6016.00	2025-11-17 16:51:37.999885	active
14	1	2	6517.00	2025-11-17 16:51:42.871551	active
15	1	2	7018.00	2025-11-17 16:51:45.31812	active
16	1	2	7519.00	2025-11-17 16:51:47.853773	active
17	2	2	7109.00	2025-11-17 16:52:43.327703	active
18	2	2	8110.00	2025-11-17 16:52:48.328066	active
19	1	2	8000.00	2025-11-17 19:22:32.409555	active
20	2	2	9000.00	2025-11-17 19:23:02.1914	active
\.


--
-- Data for Name: paintings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.paintings (id, artist_name, painting_name, image_url, base_price, status, qr_code_data, created_at, updated_at) FROM stdin;
1	Lio	Mona	https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg/500px-Mona_Lisa%2C_by_Leonardo_da_Vinci%2C_from_C2RMF_retouched.jpg	1000.00	active	PAINT1763371609302cvdtdc8b3	2025-11-17 14:56:49.302358	2025-11-17 14:56:49.302358
2	War Thunder	MiG 21 Bis	https://staticfiles.warthunder.com/upload/image/0_Wallpaper_Renders/Aircraft/1920x1080_mig_21_bison_logo_57460365449e6f79f984f3d708b73955.jpg	1000.00	active	PAINT1763372285413zce7006ya	2025-11-17 15:08:05.416826	2025-11-17 15:08:05.416826
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, first_name, last_name, mobile, password_hash, created_at, updated_at) FROM stdin;
1	Shubham	Mehta	9868467557	$2b$10$x5jbLUfAS.YwoODIFMxawO0t6ogRi7jXNKyLyU/3VQBbDby/gHGeO	2025-11-17 14:43:06.015016	2025-11-17 14:43:06.015016
2	Rajith	ps	9821751181	$2b$10$JlHy50PERDwBxdxtACqkyuNKf35y4Moy4UUxbl1b5L9mC5LZVjijK	2025-11-17 14:59:45.285412	2025-11-17 14:59:45.285412
3	sharukh	khan	9821751182	$2b$10$ac4A7IrvQszZBZsjGt6xBuctQbMOsZFGysjFPHbtMiFI5vxXbB9.6	2025-11-17 20:44:54.334788	2025-11-17 20:44:54.334788
\.


--
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.admins_id_seq', 2, true);


--
-- Name: auction_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auction_settings_id_seq', 2, true);


--
-- Name: bids_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.bids_id_seq', 20, true);


--
-- Name: paintings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.paintings_id_seq', 2, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: admins admins_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_username_key UNIQUE (username);


--
-- Name: auction_settings auction_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auction_settings
    ADD CONSTRAINT auction_settings_pkey PRIMARY KEY (id);


--
-- Name: bids bids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bids
    ADD CONSTRAINT bids_pkey PRIMARY KEY (id);


--
-- Name: paintings paintings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paintings
    ADD CONSTRAINT paintings_pkey PRIMARY KEY (id);


--
-- Name: paintings paintings_qr_code_data_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paintings
    ADD CONSTRAINT paintings_qr_code_data_key UNIQUE (qr_code_data);


--
-- Name: users users_mobile_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_mobile_key UNIQUE (mobile);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_bids_amount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bids_amount ON public.bids USING btree (bid_amount DESC);


--
-- Name: idx_bids_painting_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bids_painting_id ON public.bids USING btree (painting_id);


--
-- Name: idx_bids_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bids_user_id ON public.bids USING btree (user_id);


--
-- Name: idx_paintings_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_paintings_status ON public.paintings USING btree (status);


--
-- Name: idx_users_mobile; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_mobile ON public.users USING btree (mobile);


--
-- Name: auction_settings update_auction_settings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_auction_settings_updated_at BEFORE UPDATE ON public.auction_settings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: paintings update_paintings_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_paintings_updated_at BEFORE UPDATE ON public.paintings FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: bids bids_painting_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bids
    ADD CONSTRAINT bids_painting_id_fkey FOREIGN KEY (painting_id) REFERENCES public.paintings(id) ON DELETE CASCADE;


--
-- Name: bids bids_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bids
    ADD CONSTRAINT bids_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict ExBd0VgheDkfwlNZdkmjZUA1O9NkSHbQesOyIJzZafR5rq0K5fWc67lQmi3PCSb

