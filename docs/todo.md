# To Do

## Soft tables

Need to make an example of a soft table - will probably copy over the code for the BWARS soft table and use that as an example once it is done

## That Trigger

Still doesn't allow the addition of soft tables without modifying the trigger. Need to come up with another way to do this.

CHANGE THE TRIGGER ORDER

New record should be the 'kept copy'

- No need to change any references to ids in soft data
- Soft data can now have the ID of the record they refer to
- No need to change triggers or put fields in core
- Simpler handling of trigger and serials