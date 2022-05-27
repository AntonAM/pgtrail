# pgtrail
Auditing system for PostgreSQL

# Description

It creates new schema `pgtrail` which contains required functions and default audit storage table.
You can use function `pgtrail.enable_audit('public.table_name')` for starting auditing changes of a table.
This function will add a trigger to your table, which will be call on inserts, updates or deletes and will log
all the information to default storage table `pgtrail.audit_changes`.

You can see an example, by going to `examples/` and running `./run_example_docker.sh`. Example creates a table `employees`
and fills it with some test data, after which applies some changes so audit is generated. The script will build docker container 
for the example, start it in detached mode and then would put you into `psql` tools where you can tinker with the database.
For example, you can run `SELECT * FROM pgtrail.audit_changes;` to see all existing change. Alternatively you can use
your favourite database management tool to connect to the container on standard port 5432.

# Roadmap
- Tests
- Benchmarks
- Implement functions to get state of a record at given time (by applying changes)
- Implement automatic creation of storage table if it doesn't exist yet
- Partitioning
- Explore option for removing requirement of object_id to be uuid
- Make it an extension (?)
- Explore option for json metadata passing through transaction level 'current_setting("metadata)', fx for tracing id 
