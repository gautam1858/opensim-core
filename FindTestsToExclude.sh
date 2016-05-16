set -e

MINS_SINCE_BUILD_START=$(( (($(date +%s) - $BUILD_START_TIMESTAMP) / 60) + 1 ))
ALLTESTS=$(ctest --show-only | grep 'Test #' | sed 's/^.*: //')
for test in $ALLTESTS; do
  findres=$(find . -name "*$test" -executable -mmin +$MINS_SINCE_BUILD_START)
  if [ "$findres" != "" ]; then
    TESTS_TO_EXCLUDE="$TESTS_TO_EXCLUDE|$test"
    echo "---- Excluding test $test."
  fi
done
