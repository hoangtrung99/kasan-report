include .env

# Start time for the metric is day 24 of before month
DEFAULT_START_TIME = $(shell date -v-1m -v$(REPORT_DAY)d +'%Y-%m-%dT00:00:00')
# End time for the metric is day 24 of the current month
DEFAULT_END_TIME = $(shell date -v$(REPORT_DAY)d +'%Y-%m-%dT00:00:00')
# TOMORROW for test generate report
TOMORROW = $(shell date -v-1d +'%Y-%m-%dT00:00:00')

METRIC_FOLDER = metrics
METRIC_REPORT_FOLDER ?= ${METRIC_FOLDER}/$(shell echo ${END_TIME} | cut -d'T' -f1)

GREEN := \033[32m
RESET := \033[0m
YELLOW := \033[33m