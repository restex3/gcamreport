#!/bin/bash
# Monitor V8 test progress

PID=27379
LOG="/e/GCAM/GCAM_tools/gcamreport/output/v8_test_unlimited.log"

while ps -p $PID > /dev/null 2>&1; do
    echo "[$(date +%H:%M:%S)] Still running... Lines: $(wc -l < $LOG)"
    sleep 300  # 5 minutes
done

echo "[$(date +%H:%M:%S)] FINISHED!"
ls -lh /e/GCAM/GCAM_tools/gcamreport/output/v8_report.* 2>/dev/null && echo "SUCCESS" || echo "FAILED"
tail -20 $LOG
