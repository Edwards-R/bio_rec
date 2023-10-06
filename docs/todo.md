# To Do

## Soft tables
Need to make an example of a soft table - will probably copy over the code for the BWARS soft table and use that as an example once it is done

## That Trigger
Done! Clones are now the copy and the original remains as is. This isn't *immune* to problems, but the problems will be from *people* messing with things. That means it's *people's* responsibility to manage and fix it! Win-win!

## Soft tables queries
Will need to give an example of soft-table query. It's going to need left outer join since there's no guarantee that the soft tables are there. Probably a view that can be used as one unified table?

## Importing
Need to design an import procedure. Start with pulling data in a flat table (from The Checker), then running the spatial/temporal queries, then pushing the data to core and soft tables.