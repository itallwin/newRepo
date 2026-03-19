-- Deploy Service Desk objects into a single Oracle schema
--
-- Usage (SQL*Plus / SQLcl):
--   1) Review the DEFINE values below
--   2) Run this script with a DBA-capable account
--   3) All objects from service_desk_schema.sql will be created under one schema owner
--
-- Notes:
--   - If the schema already exists, create-user step will fail; comment it out and rerun.
--   - Keep this script in the same folder as service_desk_schema.sql.

DEFINE SD_SCHEMA   = SDOPS
DEFINE SD_PASSWORD = ChangeMe_123

PROMPT ============================================================
PROMPT Creating single schema owner: &&SD_SCHEMA
PROMPT ============================================================

CREATE USER &&SD_SCHEMA IDENTIFIED BY "&&SD_PASSWORD";
GRANT CREATE SESSION TO &&SD_SCHEMA;
GRANT CREATE TABLE TO &&SD_SCHEMA;
GRANT CREATE VIEW TO &&SD_SCHEMA;
GRANT CREATE SEQUENCE TO &&SD_SCHEMA;
GRANT CREATE TRIGGER TO &&SD_SCHEMA;
GRANT CREATE PROCEDURE TO &&SD_SCHEMA;
GRANT CREATE TYPE TO &&SD_SCHEMA;
GRANT UNLIMITED TABLESPACE TO &&SD_SCHEMA;

ALTER SESSION SET CURRENT_SCHEMA = &&SD_SCHEMA;

PROMPT ============================================================
PROMPT Deploying service desk objects in schema: &&SD_SCHEMA
PROMPT ============================================================

@service_desk_schema.sql

PROMPT ============================================================
PROMPT Deployment complete in schema: &&SD_SCHEMA
PROMPT ============================================================
