-- This procedure is designed to create a 'stub' table that can be expanded upon later by the user.
-- It is also expected that people will want to copy the query directly from here, so this procedure
-- will be heavily documented here as well as in docs/procedure/create_soft_stub.md

CREATE OR REPLACE PROCEDURE create_soft_stub()
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    tablename TEXT;
BEGIN

END;
$BODY$;