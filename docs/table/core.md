# Record

## Explanation
Stores individual record cores aka the information that is ***required*** for an occurence record to exist and function in the system.

Do not add fields to this table without *serious* consideration. Additional fields should be added to a `soft` table, which can be named as desired. Modifications to this table will require additional modifications to `core_update_trigger`.

`Soft` tables should have their id be the same as the id as the `core` record they correspond to - this is a `1: 1 - 0` relationship.


## Data Dictionary
|Attribute|Type|Description|
|---------|----|-----------|
|id|int|Auto-generated primary key of the record|
|current_id|int|The id of the current interpretation of this record|
|is_suspended|boolean|Is this record currently suspended? Worded this way so that it is possible to use `if (sum (is_suspended) > 0)`  on aggregate queries to identify duplicates of suspended data.|
|nik|int|Nomenclatural Indentification Key - the primary key of the NoNomS entry that this record relates to. Note that this is confined to a single predefined level and cannot handle multiple levels|
|easting|int|The minimum easting, in datum units, of the record's cell|
|northing|int|The minimum northing, in datum units, of the record's cell|
|accuracy|int|The size of the record's cell. `precision` would be more concise, but this is a reserved keyword in postgres so is avoided|
|datum|int|The EPSG code of the datum used|
|lower_date|date|The lower bound date of the record|
|upper_date|date|The upper bound date of the record. Can be the same as the lower bound for day-resolution records|
|suspend_reason|text|Any reason that this record is suspended. Not perfect and subject to future changes|
|added_on|timestamp+tz|The timestamp that the record was added to the system on. Automatically generated|
|modified_on|timestamp+tz|The timestamp that the record was last modified on. Automatically generated|
|added_by|text|User who added the record. Auto-entered by postgres as `session_user`|
|modified_by|text|User who last modified the core of the record. Auto-entered by postgres as `session_user`|