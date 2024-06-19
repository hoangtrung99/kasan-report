# Make kasan-report tool
# Usage: make

include variables.mk
include utils.mk

#TODO: make run default make command
.DEFAULT_GOAL := all

# Hanlde start time and end time from command line
override START_TIME := $(or $(START_TIME),$(DEFAULT_START_TIME))
override END_TIME := $(or $(END_TIME),$(DEFAULT_END_TIME))

# Handle report-today command
ifeq ($(firstword $(MAKECMDGOALS)), report-today)
  override END_TIME := $(TOMORROW)
endif

all: report-today

report: init validate report-template

report-today: START_TIME := ${START_TIME}
report-today: END_TIME := ${TOMORROW}
report-today: METRIC_REPORT_FOLDER:= ${METRIC_FOLDER}/$(shell echo ${TOMORROW} | cut -d'T' -f1)
report-today: init validate report-template

SET_VARS = START_TIME=$(START_TIME) END_TIME=$(END_TIME) \
			METRIC_REPORT_FOLDER=$(METRIC_REPORT_FOLDER)

report-template:
	@make line
	$(call print_yellow,Make kasan report)
	@make line
	@echo "Start time: $(START_TIME)"
	@echo "End time  : $(END_TIME)"
	@make line
	@make init-report-folder ${SET_VARS}
# @make http_status_403_report ${SET_VARS}
	@make http_status_500_report ${SET_VARS}
	@make synthetics_front_report ${SET_VARS}


http_status_403_report:
	@echo "Make 403 report"
	@make line
	aws cloudwatch get-metric-statistics \
		--namespace Backend --metric-name HTTP_STATUS_403 \
		--statistics Sum \
		--start-time ${START_TIME} \
		--end-time ${END_TIME} \
		--period 86400 \
		--region ap-northeast-1 | \
		jq -r '.Datapoints[] | [.Timestamp, .Sum] |\ @csv' \
		> ${METRIC_REPORT_FOLDER}/http_status_403_raw.csv
	@make line
	@make process_csv INPUT=${METRIC_REPORT_FOLDER}/http_status_403_raw.csv \
						OUTPUT=${METRIC_REPORT_FOLDER}/http_status_403.csv
	@make line

http_status_500_report:
	$(call print_yellow,Make http status 500 report)
	@make line
	aws cloudwatch get-metric-statistics \
		--namespace Backend --metric-name HTTP_STATUS_500 \
		--statistics Sum \
		--start-time ${START_TIME} \
		--end-time ${END_TIME} \
		--period 86400 \
		--region ap-northeast-1 | \
		jq -r '.Datapoints[] | [.Timestamp, .Sum] | @csv' \
		> ${METRIC_REPORT_FOLDER}/http_status_500_raw.csv
	@make line
	@make process_csv INPUT=${METRIC_REPORT_FOLDER}/http_status_500_raw.csv \
						OUTPUT=${METRIC_REPORT_FOLDER}/http_status_500.csv
	@make line

synthetics_front_report:
	$(call print_yellow,Make synthetics front report)
	@make line
	aws cloudwatch get-metric-statistics \
		--namespace CloudWatchSynthetics --metric-name SuccessPercent \
		--statistics Maximum \
		--start-time ${START_TIME} \
		--end-time ${END_TIME} \
		--period 3600 \
		--region ap-northeast-1 | \
		jq -r '.Datapoints[] | [.Timestamp, .Maximum, .Unit] | @csv' \
		> ${METRIC_REPORT_FOLDER}/synthetics_front_raw.csv
	@make line
	@make ${METRIC_REPORT_FOLDER}/synthetics_front.csv HEADER=Timestamp,Maximum,Unit
	@make line