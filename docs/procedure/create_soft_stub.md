# create_soft_stub


## Signature
create_soft_stub(
    IN table_name TEXT
)

## Arguments

### table_name
The name of the table to be created

## Explanation
Call this to create a 'stub' table suitable for soft data sets. This stub will contain 
- an auto-incrementing primary key
- a foreign key linked to `core.id`

It is expected that the user will then modify this stub of a table to suit their requirements.

## Example