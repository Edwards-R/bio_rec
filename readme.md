# Bio Rec

## What is it?
This is a template biological occurrence recording database which works at a *very* low level. It won't do everything out of the box, so be warned. However, it *is* universally applicable and designed to be extensible to specialisations, which makes it better than anything else I've seen so far.

Best used with `nonoms` to handle your nomenclature.

## Special features

### Nomenclature
Nomenclature handling via `nonoms` - no more manually updating records when taxonomy **or** nomenclature change. Do it all in `nonoms` and watch it propagate out. See the `nonoms` project for more details

### Easy pseudo-replicate identification
The core table is designed to be unique per record, allowing easy collision-checking for duplicates

### Suspension matching
Suspend one record then check to see if anything has gotten past based on any filtering you set. Simply add `WHERE SUM(is_suspended) = 0` to any aggregating query to exclude anything which is suspended or matches a suspended record

### Change tracking
When a record is changed it is duplicated rather than removed. This means that incoming records can be checked for collision to existing records and simply not imported. Repeats of corrected records simply don't make it into the system again.