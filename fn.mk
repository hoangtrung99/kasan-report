define print_green
	@echo "$(GREEN)$(1)$(RESET)"
endef

define print_yellow
	@echo "$(YELLOW)$(1)$(RESET)"
endef

define read_var
    $(foreach var,$(shell sed -n 's/^\([^=]*\)=.*/\1/p' $(1)), \
        $(eval export $(var)=$(shell sed -n 's/^$(var)=\(.*\)/\1/p' $(1))) \
    )
endef

define build_command
$(strip \
    aws cloudwatch get-metric-statistics \
    --namespace ${NAMESPACE} \
    --metric-name ${METRIC_NAME} \
    --statistics ${STATISTIC} \
    --start-time ${START_TIME} \
    --end-time ${END_TIME} \
    --period ${PERIOD} \
    $(if ${DIMENSIONS},--dimensions ${DIMENSIONS}) \
    $(if ${UNIT},--unit ${UNIT}) \
    --region ${REGION} \
    | ${TRANSFORM} > ${METRIC_REPORT_FOLDER}/${REPORT_NAME}/${REPORT_NAME}_raw.csv \
)
endef