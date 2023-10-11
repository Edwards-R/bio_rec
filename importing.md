# Importing
This section got split out from everything else as it's a complex task (or seems it when I'm starting)

## The Problem
I have a table of incoming data:
|id|c1|c2|s1|s2|
|---|---|---|---|---|
|1|A|B|aaaa|bbbb|
|2|A|A|cccc|dddd|
|3|B|A|||
|4|A|B|eeee|ffff|
|5|A|B|||
|6|B|B|gggg||

This is non-normalised and I want to split it into two tables: `core` and `soft`. Columns `c` are mandatory and will always be filled. These will go into table `core`. Columns `s` are optional and, if present, will be entered into `soft`. They will be linked via a primary key that will be created *by* table `c` to avoid having cross-table primary key sequences be effectively linked.

## Solution 1
A procedure which runs line-by-line.

1. Give it a line of data
2. Enter the `core` data, returning the inserted id
3. Look for data in the `s` fields. If there is any, insert into the `soft` table, using the `core` id as the foreign key

### The Notes
1. Making this generic as possible. The table things are placed in ready for import *can* be at least partially templated when it comes to the `core` attributes. `Soft` attributes are free game though - the trick will be to reduce the amount of custom code needed to do this import.

2. Speed? A procedure-per-line sounds like it would be super hard to optimise. However, this is an infrequent operation and not going to be part of an every-day `SELECT` query, so optimisation is *less* important.


## Solution 2
Nope, not using this one. WAY too risky

Rely on the id of the `insert` table

1. Give it a line of data
2. Enter the `core` data using the id present in the `insert` table
3. Check for data in the `s` fields. If there is any, insert into the `soft` table using the id present in the `insert` table
4. Update the primary key sequence on `core` to be the highest present

### Notes
I *really* hate manually updating primary key sequences

## Solution 3
Assign an id to every record on import, then make `core` and `import` use the same sequence to ensure continuity

1. Give it a line of data
2. Enter the `core` data using the id present in the `insert` table
3. Check for data in the `s` fields. If there is any, insert into the `soft` table using the id present in the `insert` table

### Notes
Gets rid of the need to manually update sequences

Getting pretty complex here and I'm not sure that's the right thing to do. On the other hand it's all *hardcoded* in and it'll be SUPER hard to make it go wrong - until someone tries too hard to modify things

What about cross-schema sequences? How does that work? `Import` needs to be a schema entirely separate from `data`.

-- Not a problem, works just fine

The sequence should be contained by `data`, since that can be part of the default plugin. `Import` will then 'borrow' the sequence from `data`.

## Pick
Option 3 - sharing a primary key. This means that importing is no longer something that bio_rec cares about and is appropriately exiled.