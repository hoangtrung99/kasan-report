#!/bin/bash

CONFIG_DIR="./config"

# Initialize variables
NAMESPACE=""
METRIC_NAME=""
STATISTIC="Sum"
PERIOD="86400"
REGION="ap-northeast-1"
REPORT_NAME=""

# Function to display usage
usage() {
    echo "Usage: $0 --name <report-name> [--namespace <namespace>] [--metric-name <metric-name>] [--statistic <statistic>] [--period <period>]"
    echo "  --name         The unique name for the report (required)"
    echo "  --namespace    AWS namespace (optional)"
    echo "  --metric-name  AWS metric name (optional)"
    echo "  --statistic    The statistic to retrieve (optional, default 'Sum')"
    echo "  --period       The period in seconds (optional, default '86400')"
    exit 1
}

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --name) REPORT_NAME="$2"; shift ;;
        --namespace) NAMESPACE="$2"; shift ;;
        --metric-name) METRIC_NAME="$2"; shift ;;
        --statistic) STATISTIC="$2"; shift ;;
        --period) PERIOD="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

# Check for required parameters
if [[ -z "$REPORT_NAME" ]]; then
    echo "Error: --name parameter is required."
    usage
fi

REPORT_DIR="$CONFIG_DIR/$REPORT_NAME"

# make new report dir
mkdir -p "$REPORT_DIR"

# make file command.mk
cat > "$REPORT_DIR/command.mk" <<EOF
%:
	\$(call read_var,config/\$@/var)
	@make report-setup REPORT_NAME=\$@
	@make report-result REPORT_NAME=\$@
EOF

# make file var
cat > "$REPORT_DIR/var" <<EOF
NAMESPACE=$NAMESPACE
METRIC_NAME=$METRIC_NAME
STATISTIC=$STATISTIC
PERIOD=$PERIOD
REGION=$REGION
CSV_HEADER=Timestamp,\${STATISTIC},Unit
TRANSFORM=jq -r '.Datapoints[] | [.Timestamp, .\${STATISTIC}, .Unit] | @csv'
DIMENSIONS=
UNIT=
EOF

# make file image-widget.json
cat > "$REPORT_DIR/image_widget.json" <<EOF
{
  "width": 1200,
  "height": 720,
  "view": "timeSeries",
  "stacked": false,
  "metrics": [["\${NAMESPACE}", "\${METRIC_NAME}", { "stat": "\${STATISTIC}" }]],
  "period": "\${PERIOD}",
  "start": "\${START_TIME}",
  "end": "\${END_TIME}",
  "region": "\${REGION}"
}
EOF

echo "Report $REPORT_NAME created successfully."