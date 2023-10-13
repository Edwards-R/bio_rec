EXTENSION = biorec
EXTVERSION = 0.0.3

# This looks for a target. If it can't find it, it makes it
DATA = $(EXTENSION)--$(EXTVERSION).sql

# This is a target
$(EXTENSION)--$(EXTVERSION).sql: \
	trigger/*.sql \
	procedure/*.sql
		cat $^ > $@

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)