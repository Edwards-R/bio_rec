CREATE OR REPLACE PROCEDURE create_soft_stub(
    tablename TEXT
)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE

BEGIN
    EXECUTE format('
        CREATE TABLE IF NOT EXISTS @extschema@.%I (
            id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
            core_id integer NOT NULL REFERENCES @extschema@.core(id) -- Lock the fk to the pk directly
        );',
        tablename
    );

    -- index on the core_id to make things faster
    EXECUTE format('
        CREATE INDEX ON @extschema@.%I (core_id);
        ',
        tablename
    );
    
END;
$BODY$;