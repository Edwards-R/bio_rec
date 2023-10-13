-- This procedure is designed to create a 'stub' table that can be expanded upon later by the user.
-- It is also expected that people will want to copy the query directly from here, so this procedure
-- will be heavily documented here as well as in docs/procedure/create_soft_stub.md

CREATE OR REPLACE PROCEDURE create_soft_stub(
    tablename TEXT
)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE

BEGIN
    EXECUTE format(
        'CREATE TABLE IF NOT EXISTS @extschema@.%I (
            id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
            core_id integer NOT NULL REFERENCES @extschema@.core(id) -- Lock the fk to the pk directly
        );',
        tablename
    );
END;
$BODY$;