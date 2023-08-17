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
$BODY$;