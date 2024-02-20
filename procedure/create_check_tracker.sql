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

    CREATE INDEX id ON @extschema@.check_tracker(id);
    CREATE INDEX core_id ON @extschema@.check_tracker(core_id);

    -- Add a view to display the *current* status of any record
    CREATE VIEW @extschema@.check_current AS(
        WITH pick AS (
            SELECT max(id) as id
            FROM @extschema@.check_tracker
            GROUP BY core_id
        )

        SELECT core_id, is_suspended
        FROM @extschema@.check_tracker
        JOIN pick on check_tracker.id=pick.id
    );
END;
$BODY$;
