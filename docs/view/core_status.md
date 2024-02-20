# Core Status

## Explanation
A view which displays whether a core record is currently suspended or not.


## Data Dictionary
|Attribute|Type|Description|
|---------|----|-----------|
|id|int|Auto-generated primary key of the record|
|core_id|int|The id of the core record that this record relates to|
|is_suspended|boolean|Did the check result in the suspension of the record?|
|notes|text|Anything that needs to be recorded alongside the check. Details, reasons, validation, results etc|