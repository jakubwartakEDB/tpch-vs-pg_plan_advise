# tpch-vs-pg_plan_advise

The idea is to run whole suite of real-world queries (e.g. TPC-H) , collect plan_advices
and feed them back to the pg_plan_advice and see which one were used and which couldn't
be used due to some conflict/incapability/duplicates or bugs if any.

prepare:
* createdb dbt3  
* bunzip2 dbt3_tpch_1GB_dump files
* import dbt3_tpch_1GB_dump to dbt3 postgresdb using pg_restore  
* alter system set shared_preload_libraries = 'pg_plan_advice';
* pg_ctl restart

# Run

The below will try to find advices that couldn't be used(?)
run: ./analyzeit.sh 


# TPC-H Queries

This repository contains SQL queries derived from the TPC-H benchmark:
* These queries are derived from the TPC-H™ Benchmark and do not contain any
benchmark or runtime results.
* TPC-H and TPC are trademarks of the Transaction Processing Performance Council.
* This repository is for educational/functional testing and research purposes only.

