#!/usr/bin/env bash -e

NUM_PROCESSES=0
NUM_LOOPS=0
WAITALL_DELAY=1

while [ "$1" != "" ]; do
    case "$1" in
      "-NumBackGroundProcesses")
        NUM_PROCESSES=$2
        shift; shift
        ;;
      "-NumberLoop")
        NUM_LOOPS=$2
        shift; shift
        ;;
      *)
        echo "Unexpected argument: $1"
        exit 1
        ;;
    esac
done

if [ $NUM_PROCESSES -eq 0 ] ; then
    echo "Must specify at-least one background processes."
    exit 1
fi

if [ $NUM_LOOPS -eq 0 ] ; then
    echo "Must specify at-least one loop."
    exit 1
fi

echo $NUM_PROCESSES $NUM_LOOPS

declare -a pids
# run processes and store pids in array
for i in `seq 1 $NUM_PROCESSES`; do
    ./gradlew testRelease $NUM_LOOPS &
    pids[${i}]=$!
    echo "Test ${pids[i]} started at $(date)."
done

waitall() { # PID...
  ## Wait for children to exit and indicate whether all exited with 0 status.
  local errors=0
  while :; do
    for pid in "$@"; do
      shift
      if kill -0 "$pid" 2>/dev/null; then
        set -- "$@" "$pid"
      elif wait "$pid"; then
        debug "Test $pid finished successfully at $(date)."
      else
        error "Test $pid failed at $(date)."
        ((++errors))
      fi
    done
    (("$#" > 0)) || break
    sleep ${WAITALL_DELAY:-1}
  done
  ((errors == 0))
}

debug() { echo "DEBUG: $*" >&2; }
error() { echo "ERROR: $*" >&2; }

# wait for all pids
waitall ${pids[*]}
