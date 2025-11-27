-- -------------------------------
-- 1) Assignment 1: create/reset dwh2_xxx schema per group
-- -------------------------------
DROP SCHEMA IF EXISTS dwh2_xxx CASCADE;
CREATE SCHEMA dwh2_xxx AUTHORIZATION grp_xxx;
