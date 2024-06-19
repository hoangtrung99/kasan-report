include variables.mk

.PHONY: init validate line print_aws_credential_docs init-report-folder

init:
	@mkdir -p ${METRIC_FOLDER}

init-report-folder:
	@echo "Init report folder: metrics/$(shell echo ${END_TIME} | cut -d'T' -f1)"
	@mkdir -p metrics/$(shell echo ${END_TIME} | cut -d'T' -f1)
	@make line

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

define print_green
	@echo "$(GREEN)$(1)$(RESET)"
endef

define print_yellow
	@echo "$(YELLOW)$(1)$(RESET)"
endef

# process_csv
%.csv: %_raw.csv
	$(call print_green,Processing and formatting CSV file: $@)
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

clean:
	rm -rf ${METRIC_FOLDER}
