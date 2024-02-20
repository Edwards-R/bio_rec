CREATE VIEW @extschema@.core_status AS

WITH cur AS (
	SELECT max(id) id
	FROM @extschema@.check_tracker
	GROUP BY core_id
)

SELECT t.*
FROM @extschema@.check_tracker t
JOIN cur c ON t.id = c.id
