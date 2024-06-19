
# Start time for the metric is day 24 of before month
DEFAULT_START_TIME = $(shell date -v-1m -v21d +'%Y-%m-%dT00:00:00')
# End time for the metric is day 24 of the current month
DEFAULT_END_TIME = $(shell date -v21d +'%Y-%m-%dT00:00:00')
# TOMORROW for test generate report
TOMORROW = $(shell date -v-1d +'%Y-%m-%dT00:00:00')

METRIC_FOLDER = metrics
METRIC_REPORT_FOLDER ?= ${METRIC_FOLDER}/$(shell echo ${END_TIME} | cut -d'T' -f1)