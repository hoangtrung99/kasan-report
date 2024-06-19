# Make kasan-report tool
# Usage: make

include variables.mk
include utils.mk

COMMAND_MKS := $(wildcard config/*/command.mk)
$(foreach mk,$(COMMAND_MKS),$(eval include $(mk)))


.PHONY: all report report-today report-template

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

REPORTS := $(patsubst config/%/command.mk,%,$(COMMAND_MKS))


report-template:
	@make line
	$(call print_yellow,Make kasan report)
	@make line
	@echo "Start time: $(START_TIME)"
	@echo "End time  : $(END_TIME)"
	@make line
	@make init-report-folder ${SET_VARS}
#	@make http_status_500_report ${SET_VARS}
#	@make synthetics_front_report ${SET_VARS}
#	auto run all reports
	@make create-report ${SET_VARS}

define run_report
	$(@info Make $(1))
	@make $(1) $(SET_VARS)
endef

create-report:
	$(foreach report,$(REPORTS),$(call run_report,$(report)))