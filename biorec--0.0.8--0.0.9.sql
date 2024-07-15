CREATE OR REPLACE FUNCTION core_update_trigger()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

DECLARE
	trap_id INTEGER;
BEGIN
    -- Check that the record can indeed be modified in this way i.e. record is not already a parent
	IF OLD.id != OLD.current_id THEN
		RAISE EXCEPTION 'Cannot modify a non-current record, please modify the current one if needed';
	END IF;

    -- Add a copy of the old to the database and point it to the new
    INSERT INTO @extschema@.core (
        current_id,
        nik,
        easting,
        northing,
        accuracy,
        datum,
        lower_date,
        upper_date,
        modified_on,
        modified_by,
        added_by,
        added_on
    ) VALUES (
        OLD.current_id,
        OLD.nik,
        OLD.easting,
        OLD.northing,
        OLD.accuracy,
        OLD.datum,
        OLD.lower_date,
        OLD.upper_date,
        OLD.modified_on,
        OLD.modified_by,
        OLD.added_by,
        OLD.added_on
    ) RETURNING id INTO trap_id;

    -- Set the trap record to be suspendede
    INSERT INTO @extschema@.check_tracker(core_id, is_suspended, notes) VALUES (old.id, true, 'Trap record');

    -- Set modification details
    NEW.modified_by = session_user;
    NEW.modified_on = now();

    -- Now release the modified version so that the changes are applied to it
    RETURN NEW;
END;
$BODY$;