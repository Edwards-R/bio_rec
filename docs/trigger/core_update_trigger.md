# core_update_trigger

## Explanation

This trigger takes care of parent-childing modifications to a core. Rather than update a record, a clone of that record is made and then changed. The old record is then redirected to the new. The reason for this is that the database is not the sole authority for data - these records most often continue to exist, in their pre-change state, outside of the database. Should these records, with faults, be re-imported to the database, the faulty record would be imported all over again. By maintaining a copy of the 'wrong' record the import routine will have a collision and so not import the wrong record again. Because this wrong record is marked as suspended, it can easily be filtered out, as well as identifying anything that collides with it that is already in the database to be filtered. The process also creates an audit trail for easy checking. It also allows checking an externally sourced record against the BWARS database, regardless of whether or not we've changed said record. Absence of data is not the same as a null result, especially if the system creates null returns as a default - fundamental engineering principles again. Don't make something null unless that meaning is strictly controlled. In this case, null could mean 'we don't have the record', or it could be 'we had the record but we changed it, but we can't tell'. This is not strictly controlled, and so fails the check.

Only core field updates trigger this function
 * nik
 * easting/northing/accuracy/datum
 * lower/upper bound date

### Shorter version
The trigger clones the target record when specific attributes are modified. This clone is then
 - marked as suspended
 - current_id set to the original record's id
 - given the suspend reason
 - saved into the database

The original record is then:
 - modified as per user's wishes
 - on_update timestamp/user updated
 - suspend_reason cleared (see 'old clone' for the suspend reason)