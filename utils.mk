include variables.mk
include fn.mk

.PHONY: init validate line print_aws_credential_docs init-report-folder

init:
	@mkdir -p ${METRIC_FOLDER}

init-report-folder:
	@echo "Init report folder: metrics/$(shell echo ${END_TIME} | cut -d'T' -f1)"
	@mkdir -p metrics/$(shell echo ${END_TIME} | cut -d'T' -f1)
	@make line

init-report-sub-folder:
	@mkdir -p ${METRIC_REPORT_FOLDER}/${REPORT_NAME}

validate:
	@if [ -z "$(AWS_PROFILE)" ]; then \
		$(MAKE) print_aws_credential_docs; \
		exit 1; \
	fi

line:
	@echo "-------------------------------------------------------------------------------------"


required_jq:
	@echo "jq is required to run. \
	Please refer to the following link for more information: \
	https://stedolan.github.io/jq/download/"
	@make line
	@echo "You can install jq using the following commands: \n\
	1. For MacOS: brew install jq \n\
	2. For Linux: sudo apt-get install jq"

print_aws_credential_docs:
	@echo "AWS credentials are required to run. \
	Please refer to the following link for more information: \
	https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html"
	@make line
	@echo "You can set the AWS credentials in the following ways: \n\
	1. Set the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables. Or config \
	credentials in the ~/.aws/credentials file. \n\
	2. Set the AWS_PROFILE environment variable to the profile name in the AWS credentials file."

clean:
	rm -rf ${METRIC_FOLDER}

HEADER = Timestamp,Sum
process_csv:
	@echo "$(GREEN)Processing and formatting CSV file: $(OUTPUT)$(RESET)"
	@echo "$(HEADER)" > $(OUTPUT)
	@sort -t',' -k1,1 $(INPUT) | \
		awk 'BEGIN {FS=","; OFS=","} \
		     { \
		       for (i = 1; i <= NF; i++) { \
		         gsub(/\"/, "", $$i); \
		         if (i == 1) { \
		           gsub(/Z/, "", $$i); \
		           gsub(/T/, " ", $$i); \
		           gsub(/\+00:00/, "", $$i); \
		         } \
		         printf (i < NF ? "\"%s\"," : "\"%s\"\n", $$i); \
		       } \
		     }' >> $(OUTPUT)


# process_csv
%.csv: %_raw.csv
	$(call print_green,Processing and formatting CSV file: \n$@)
	@echo "$(HEADER)" > $@
	@sort -t',' -k1,1 $< | \
		awk 'BEGIN {FS=","; OFS=","} \
		     { \
		       for (i = 1; i <= NF; i++) { \
		         gsub(/\"/, "", $$i); \
		         if (i == 1) { \
		           gsub(/Z/, "", $$i); \
		           gsub(/T/, " ", $$i); \
		           gsub(/\+00:00/, "", $$i); \
		         } \
		         printf (i < NF ? "\"%s\"," : "\"%s\"\n", $$i); \
		       } \
		     }' >> $@

report-chart:
	$(call print_green,"Make ${REPORT_NAME} chart...")
	@make line
	@export START_TIME=${START_TIME} END_TIME=${END_TIME} && \
	aws cloudwatch get-metric-widget-image \
         --metric-widget "$$(envsubst < config/${REPORT_NAME}/image_widget.json | jq '.period |= tonumber')" \
        --output-format png \
        --output text \
        |  base64 -d > ${METRIC_REPORT_FOLDER}/${REPORT_NAME}/${REPORT_NAME}_chart.png
	${call print_green,"Make ${REPORT_NAME} chart ok!"}
	

report-setup:
	$(call print_yellow,"Make ${REPORT_NAME}")
	@make init-report-sub-folder
	@make line
	aws cloudwatch get-metric-statistics \
		--namespace ${NAMESPACE} --metric-name ${METRIC_NAME} \
		--statistics ${STATISTIC} \
		--start-time ${START_TIME} \
		--end-time ${END_TIME} \
		--period ${PERIOD} \
		$(if $(DIMENSIONS),--dimensions ${DIMENSIONS}) \
		$(if $(UNIT),--unit ${UNIT}) \
		--region ${REGION} | \
		${TRANSFORM} > \
		${METRIC_REPORT_FOLDER}/${REPORT_NAME}/${REPORT_NAME}_raw.csv

report-result:
	@make line
	@make ${METRIC_REPORT_FOLDER}/${REPORT_NAME}/${REPORT_NAME}.csv HEADER=${CSV_HEADER}
	@make line
	@make report-chart
	@make line