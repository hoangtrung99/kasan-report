# Make kasan-report tool
# Usage: make

include variables.mk
include utils.mk

#TODO: make run default make command
# .DEFAULT_GOAL := all

all: report-today

report: START_TIME := ${START_TIME}
report: END_TIME := ${END_TIME}
report: init validate report-template

report-today: START_TIME := ${START_TIME}
report-today: END_TIME := ${TOMORROW}
report-today: METRIC_REPORT_FOLDER:= ${METRIC_FOLDER}/$(shell echo ${TOMORROW} | cut -d'T' -f1)
report-today: init validate report-template

SET_VARS = START_TIME=$(START_TIME) END_TIME=$(END_TIME) \
			METRIC_REPORT_FOLDER=$(METRIC_REPORT_FOLDER)

report-template:
	@echo "Make report"
	@make line
	@echo "Start time: $(START_TIME)"
	@echo "End time  : $(END_TIME)"
	@make line
	@make init-report-folder ${SET_VARS}
	@make http_status_403_report ${SET_VARS}


http_status_403_report:
	@echo "Make 403 report"
	aws cloudwatch get-metric-statistics \
	--namespace Backend --metric-name HTTP_STATUS_403 \
	--statistics Sum \
	--start-time ${START_TIME} \
	--end-time ${END_TIME} \
	--period 3000 \
	--region ap-northeast-1 > ${METRIC_REPORT_FOLDER}/403.txt