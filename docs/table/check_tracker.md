# Check tracker

## Explanation
Keeps track of checks performed on individual records. Checks are typically performed on outlier records, either spatial or temporal. It is important to keep track of positive checks i.e. no suspension as well as negative i.e. suspension as it stops the check being repeatedly performed in the case of success. There are some *very* odd records that exist out there that are entirely legitimate, but that constantly get queried as to their validity. This system should stop that happening somewhat.


## Data Dictionary
|Attribute|Type|Description|
|---------|----|-----------|
|id|int|Auto-generated primary key of the record|
|core_id|int|The id of the core record that this record relates to|
|is_suspended|boolean|Did the check result in the suspension of the record?|
|notes|text|Anything that needs to be recorded alongside the check. Details, reasons, validation, results etc|
