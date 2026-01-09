#!/bin/bash

#TODO compare plans before and after! too

PORT=1234

# to run just one qXX, uncomment the next line, results will be in /tmp/advice
# and /tmp/result
for F in `ls -1 q*.sql | sort -n`; do
#for F in q5.sql; do
	echo $F;

	# get advice from explain
	psql -Antb -p $PORT -h /tmp dbt3 -c 'ANALYZE;'
	echo 'explain (plan_advice, timing off, costs off, settings off, memory off, format json)' > tmp.sql
	cat $F >> tmp.sql
	ADVICE=`psql -Antb -p $PORT -h /tmp dbt3 -f tmp.sql | jq -sr '.[].[]."Generated Plan Advice"'`
	#echo -e "$F: got $ADVICE"

	echo 'explain (timing off, costs off, settings off, memory off)' > tmp.sql
	cat $F >> tmp.sql
	PLAN=`psql -Antb -p $PORT -h /tmp dbt3 -f tmp.sql`

	
	psql -Antb -p $PORT -h /tmp dbt3 -c "select pg_clear_relation_stats('public', relname) from pg_class where relnamespace = 2200 and relkind = 'r';"
	# get what was matched
	echo -e "set pg_plan_advice.advice = '$ADVICE';" > tmp.sql;
	echo 'explain (plan_advice, timing off, costs off, settings off, memory off, format json)' >> tmp.sql
	cat $F >> tmp.sql
	RESULT=`psql -Antb -p $PORT -h /tmp dbt3 -f tmp.sql | grep -v ^SET | jq -sr '.[].[]."Supplied Plan Advice"'`
	#echo "$F: got $RESULT"

	echo -e "set pg_plan_advice.advice = '$ADVICE';" > tmp.sql;
	echo -e "set pg_plan_advice.always_explain_supplied_advice to 'off';" >> tmp.sql;
	echo 'explain (timing off, costs off, settings off, memory off)' >> tmp.sql
	cat $F >> tmp.sql
	PLANADVICED=`psql -Antb -p $PORT -h /tmp dbt3 -f tmp.sql`

	echo "$ADVICE" > /tmp/advice
	echo "$RESULT" > /tmp/result
	echo "$PLAN" > /tmp/plan
	echo "$PLANADVICED" | grep -v '^SET' > /tmp/planadviced

	#diff -u /tmp/advice /tmp/result
	# sed for identing whole output for easier readability:
	grep -v \
		-e '\/\* matched \*\/' \
		-e '\/\* matched, conflicting \*\/' \
		/tmp/result | sed 's/^/\t/'

	diff -u /tmp/plan /tmp/planadviced

done
