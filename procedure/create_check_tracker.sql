CREATE OR REPLACE PROCEDURE create_check_tracker()
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE

BEGIN
    CREATE TABLE IF NOT EXISTS @extschema@.check_tracker(
        id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
        core_id integer NOT NULL REFERENCES @extschema@.core(id), -- Lock the fk to the pk directly
        is_suspended boolean NOT NULL,
        timestamp timestamp with time zone NOT NULL DEFAULT now(),
        notes text
    );

    --Indexes
    CREATE INDEX core_id ON @extschema@.check_tracker(core_id);

END;
$BODY$;
