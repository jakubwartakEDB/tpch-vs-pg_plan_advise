# tpch-vs-pg_plan_advise

The idea is to run whole suite of real-world queries (e.g. TPC-H) , collect plan_advices
and feed them back to the pg_plan_advice and see which one were used and which couldn't
be used due to some conflict/incapability/duplicates or bugs if any.

prepare:
createdb dbt3
bunzip2 dbt3_tpch_1GB.sql.bz2
import dbt3_tpch_1GB_dump to dbt3 postgresdb using pg_restore
alter system set shared_preload_libraries = 'pg_plan_advice';
pg_ctl restart

The below will try to find advices that were not found
run: ./analyzeit.sh 

