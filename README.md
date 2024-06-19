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
