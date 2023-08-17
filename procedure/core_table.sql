CREATE OR REPLACE PROCEDURE create_core()
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
    modified_by TEXT NOT NULL DEFAULT session_user
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
CREATE INDEX IF NOT EXISTS record_lower_date
    ON @extschema@.core USING btree
    (lower_date ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS record_nik
    ON @extschema@.core USING btree
    (nik ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS record_upper_date
    ON @extschema@.core USING btree
    (upper_date ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE TRIGGER pre_update_change
    BEFORE UPDATE OF nik, easting, northing, accuracy, datum, lower_date, upper_date
    ON @extschema@.record
    FOR EACH ROW
    EXECUTE FUNCTION @extschema@.core_update_trigger();
END;
$BODY$;