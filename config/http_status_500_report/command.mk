%:
	$(call read_var,config/$@/var)
	@make report-setup REPORT_NAME=$@
	@make report-result REPORT_NAME=$@