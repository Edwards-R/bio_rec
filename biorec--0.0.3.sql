CREATE OR REPLACE FUNCTION core_update_trigger()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

DECLARE
	
BEGIN
    -- Check that the record can indeed be modified in this way i.e. record is not already a parent
	IF OLD.id != OLD.current_id THEN
		RAISE EXCEPTION 'Cannot modify a parent record, please modify child';
	END IF;

    -- Add a copy of the old to the database and point it to the new
    INSERT INTO @extschema@.core (
        current_id,
        is_suspended,
        nik,
        easting,
        northing,
        accuracy,
        datum,
        lower_date,
        upper_date,
        suspend_reason,
        modified_on,
        modified_by,
        added_by,
        added_on
    ) VALUES (
        OLD.current_id,
        TRUE,
        OLD.nik,
        OLD.easting,
        OLD.northing,
        OLD.accuracy,
        OLD.datum,
        OLD.lower_date,
        OLD.upper_date,
        NEW.suspend_reason, -- Note new
        OLD.modified_on,
        OLD.modified_by,
        OLD.added_by,
        OLD.added_on
    );

    -- Remove the suspend reason from new (hack-y, but needs ANOTHER rewrite ontop of this and I don't have the time)
    NEW.suspend_reason = NULL;
    

    -- Set modification details
    NEW.modified_by = session_user;
    NEW.modified_on = now();

    -- Now release the modified version so that the changes are applied to it
    RETURN NEW;
END;
$BODY$;CREATE OR REPLACE PROCEDURE create_check_tracker()
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE

BEGIN
    CREATE TABLE IF NOT EXISTS @extschema@.check_tracker(
        id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
        core_id integer NOT NULL REFERENCES @extschema@.core(id), -- Lock the fk to the pk directly
        is_suspended boolean NOT NULL,
        notes text
    );
END;
$BODY$;
CREATE OR REPLACE PROCEDURE create_core()
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE

BEGIN
    CREATE TABLE IF NOT EXISTS @extschema@.core
(
    id integer NOT NULL,
    current_id integer NOT NULL,
    nik integer NOT NULL,
    easting integer NOT NULL,
    northing integer NOT NULL,
    accuracy integer NOT NULL,
    datum integer NOT NULL,
    lower_date date NOT NULL,
    upper_date date NOT NULL,
    suspend_reason text COLLATE pg_catalog."default",
    added_on timestamp with time zone NOT NULL DEFAULT now(),
    modified_on timestamp with time zone NOT NULL DEFAULT now(),
    added_by TEXT NOT NULL DEFAULT session_user,
    modified_by TEXT NOT NULL DEFAULT session_user,
    CONSTRAINT record_pkey PRIMARY KEY (id)
);

-- Create the primary key sequence. We're gonna be using current and nextval both, so we have to do this manually
CREATE SEQUENCE IF NOT EXISTS @extschema@.core_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1
    OWNED BY @extschema@.core.id;

-- Set id to nextval
ALTER TABLE @extschema@.core ALTER COLUMN id SET DEFAULT nextval('@extschema@.core_id_seq'::regclass);

-- Set current_id to currval
ALTER TABLE @extschema@.core ALTER COLUMN current_id SET DEFAULT currval('@extschema@.core_id_seq'::regclass);

--Indexes
CREATE INDEX IF NOT EXISTS core_lower_date
    ON @extschema@.core USING btree
    (lower_date ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS core_nik
    ON @extschema@.core USING btree
    (nik ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS core_upper_date
    ON @extschema@.core USING btree
    (upper_date ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE TRIGGER core_update_change
    BEFORE UPDATE OF nik, easting, northing, accuracy, datum, lower_date, upper_date
    ON @extschema@.core
    FOR EACH ROW
    EXECUTE FUNCTION @extschema@.core_update_trigger();
END;
$BODY$;-- This procedure is designed to create a 'stub' table that can be expanded upon later by the user.
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