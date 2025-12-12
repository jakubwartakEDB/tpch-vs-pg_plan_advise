#!/bin/bash

# to run just one qXX, uncomment the next line, results will be in /tmp/advice
# and /tmp/result
for F in `ls -1 q*.sql | sort -n`; do
#for F in q10.sql; do
	echo $F;

	# get advice from explain
	echo 'explain (plan_advice, timing off, costs off, settings off, memory off, format json)' > tmp.sql
	cat $F >> tmp.sql
	ADVICE=`psql -Antb -p 5432 -h /tmp dbt3 -f tmp.sql | jq -sr '.[].[]."Generated Plan Advice"'`
	#echo -e "$F: got $ADVICE"

	# get what was matched
	echo -e "set pg_plan_advice.advice = '$ADVICE';" > tmp.sql;
	echo 'explain (plan_advice, timing off, costs off, settings off, memory off, format json)' >> tmp.sql
	cat $F >> tmp.sql
	RESULT=`psql -Antb -p 5432 -h /tmp dbt3 -f tmp.sql | grep -v ^SET | jq -sr '.[].[]."Supplied Plan Advice"'`
	#echo "$F: got $RESULT"

	echo "$ADVICE" > /tmp/advice
	echo "$RESULT" > /tmp/result

	#diff -u /tmp/advice /tmp/result
	# sed for identing whole output for easier readability:
	grep -v \
		-e '\/\* matched \*\/' \
		-e '\/\* matched, conflicting \*\/' \
		/tmp/result | sed 's/^/\t/'

done
