# Prerequisites

1. Setup aws credentials profile in `~/.aws/credentials`, e.g.

```yml
[kasan-prod]
aws_access_key_id = AKIA...
aws_secret_access_key = ...
```

2. Export the profile name as an environment variable

```shell
export AWS_PROFILE=kasan-prod
```

3. Install `jq` and `aws-cli` if you haven't already.

# Usage:

```shell

- make # make report from 21th past month to 21th this month
- make report-today # make report from 21th past month to today
- make report START_TIME={start_time} END_TIME={end_time} # make report from {start_time} to {end_time}
```

# Add a new report

1. Make sure new_report.sh is executable

```shell
chmod +x new_report.sh
```

2. run the script, you can use the arguments or change file var in `config/{report-name}/var` after running the script

```shell
Usage: ./new_report.sh --name <report-name> [--namespace <namespace>] [--metric-name <metric-name>] [--statistic <statistic>] [--period <period>]
  --name         The unique name for the report (required)
  --namespace    AWS namespace (optional)
  --metric-name  AWS metric name (optional)
  --statistic    The statistic to retrieve (optional, default 'Sum')
  --period       The period in seconds (optional, default '86400')
```
