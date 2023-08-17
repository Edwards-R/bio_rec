CREATE OR REPLACE FUNCTION core_update_trigger()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

DECLARE
	new_id INTEGER;

BEGIN
	--Check that the record can indeed be modified in this way i.e. record is not already a parent
	IF old.id != old.current_id THEN
		RAISE EXCEPTION 'Cannot modify a parent record, please modify child';
	END IF;

	--Make the 'fake' new record manually

	INSERT INTO @extschema@.record (
		current_id,
		is_suspended,
		nik,
		easting,
		northing,
		accuracy,
		datum,
		lower_date,
		upper_date,
		added_on,
		modified_on,
        added_by,
		modified_by
	) VALUES (
		currval(pg_get_serial_sequence('@extschema@.core','id')),
		false,
		NEW.nik,
		NEW.easting,
		NEW.northing,
		NEW.accuracy,
		NEW.datum,
		NEW.lower_date,
		NEW.upper_date,
		NEW.added_on,
		NOW(),
        NEW.added_by,
		session_user
	);

	--now read the current serial of the session since it has been updated by the creation
	new_id:=currval(pg_get_serial_sequence('@extschema@.core','id'));
	--Set the 'current id' of the OLD record to the NEWLY CREATED
	OLD.current_id=new_id;
	--Suspend the old
	OLD.is_suspended = true;
	--Append the new suspend reason back to the old. Not perfect but have to do this one step at a time
	OLD.suspend_reason = CONCAT(OLD.suspend_reason,'
',NEW.suspend_reason);
	--Return out the old with the modified suspend reason
	RETURN OLD;
END;
$BODY$;CREATE OR REPLACE PROCEDURE create_core()
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE

BEGIN
    CREATE TABLE IF NOT EXISTS @extschema@.core
(
    id integer NOT NULL,
    current_id integer NOT NULL,
    is_suspended boolean NOT NULL,
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
$BODY$;