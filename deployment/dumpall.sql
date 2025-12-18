--
-- PostgreSQL database cluster dump
--

\restrict w7YkvykqIeIDhX6DRHoUnIPbPUMo0hadF6ddkOJTzF3BFAjYjWgQZE21hRgQmuY

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:ZdGlrHCt/NQ7B3FA4KbLUw==$MLkNaa6tIAr/YVMNGY0fSYFNm2nPSA1LA2r+RBGzQtY=:rv+aUyPURED4SNzt1v0S+fjd3m5OhjMc8GTFIOZzQr0=';

--
-- User Configurations
--








\unrestrict w7YkvykqIeIDhX6DRHoUnIPbPUMo0hadF6ddkOJTzF3BFAjYjWgQZE21hRgQmuY

--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

\restrict qxIf1hdWwWqfDVI0HwFK5FefAgvSQinEwrUKnVcf8NyqBYscQzgQWNoetfxBGzQ

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

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
-- PostgreSQL database dump complete
--

\unrestrict qxIf1hdWwWqfDVI0HwFK5FefAgvSQinEwrUKnVcf8NyqBYscQzgQWNoetfxBGzQ

--
-- Database "openproject" dump
--

--
-- PostgreSQL database dump
--

\restrict OhJYxXvPlysqbiNdVVjS9vULaAY5sZxVpkKwzY2QKZrvNTPwyOdpffvBjggrCMe

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

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
-- Name: openproject; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE openproject WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE openproject OWNER TO postgres;

\unrestrict OhJYxXvPlysqbiNdVVjS9vULaAY5sZxVpkKwzY2QKZrvNTPwyOdpffvBjggrCMe
\connect openproject
\restrict OhJYxXvPlysqbiNdVVjS9vULaAY5sZxVpkKwzY2QKZrvNTPwyOdpffvBjggrCMe

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
-- PostgreSQL database dump complete
--

\unrestrict OhJYxXvPlysqbiNdVVjS9vULaAY5sZxVpkKwzY2QKZrvNTPwyOdpffvBjggrCMe

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

\restrict unb05FgoJsgbbfeoFUh9ds3ZBODPcM0ou0ttcJvqRq0FXp72QYQs3gK3I34ojxm

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

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
-- PostgreSQL database dump complete
--

\unrestrict unb05FgoJsgbbfeoFUh9ds3ZBODPcM0ou0ttcJvqRq0FXp72QYQs3gK3I34ojxm

--
-- PostgreSQL database cluster dump complete
--

