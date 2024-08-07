 [![GitHub: fourdollars/launchpad-bug-resource](https://img.shields.io/badge/GitHub-fourdollars%2Flaunchpad%E2%80%90bug%E2%80%90resource-darkgreen.svg)](https://github.com/fourdollars/launchpad-bug-resource/) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT) [![Bash](https://img.shields.io/badge/Language-Bash-red.svg)](https://www.gnu.org/software/bash/) ![Docker](https://github.com/fourdollars/launchpad-bug-resource/workflows/Docker/badge.svg) [![Docker Pulls](https://img.shields.io/docker/pulls/fourdollars/launchpad-bug-resource.svg)](https://hub.docker.com/r/fourdollars/launchpad-bug-resource/)
# launchpad-bug-resource
[concourse-ci](https://concourse-ci.org/)'s launchpad-bug-resource to watch the Launchpad bug status changes by using https://api.launchpad.net/.

## Config 

### Resource Type

```yaml
resource_types:
- name: resource-launchpad-bug
  type: registry-image
  source:
    repository: fourdollars/launchpad-bug-resource
    tag: latest
  defaults:
    oauth_consumer_key: test
    oauth_token: csjrGznX4Jq59CB8941N
    oauth_token_secret: wxDNqsCLxzrmhb2K27FRGjc7hdp3zQk0b4N8cnfRzVHnJfCFlHgkGHxDk5qMPTSdQFSsllS4dwGBD18Q
    timeout: 10s
```

or

```yaml
resource_types:
- name: resource-launchpad-bug
  type: registry-image
  source:
    repository: ghcr.io/fourdollars/launchpad-bug-resource
    tag: latest
  defaults:
    oauth_consumer_key: test
    oauth_token: csjrGznX4Jq59CB8941N
    oauth_token_secret: wxDNqsCLxzrmhb2K27FRGjc7hdp3zQk0b4N8cnfRzVHnJfCFlHgkGHxDk5qMPTSdQFSsllS4dwGBD18Q
    timeout: 10s
```

### Resource

* oauth_consumer_key: **required**, choose what you like.
* oauth_token: **required**, run `oauth_consumer_key=what_you_like lp-api` to get it in ~/.config/lp-api.toml. https://github.com/fourdollars/lp-api
* oauth_token_secret: **required**, run `oauth_consumer_key=what_you_like lp-api` to get it in ~/.config/lp-api.toml. https://github.com/fourdollars/lp-api
* timeout: optional, the timeout duration for lp-api. It is 10s by default.
* id: optional, the bug id or bug id list.
* project: optional, Specify the project name to search bugs.
 * tag: optional, the tag or tag list. Specify the tag when it searches for the project.
 * status: optional, one status of "New", "Incomplete", "Opinion", "Invalid", "Won't Fix", "Expired", "Confirmed", "Triaged", "In Progress", "Fix Committed", "Fix Released", "*" or the list. Specify the status when it searches for the project.
 * combinator: 'any' or 'all'. Specify the tag combinator when it searches for the project. 'any' by default.
 * modified_since: optional, it is disabled by default. When it is enabled, it will only check those modified bugs since the date last updated.
 * created_before: optional, it is disabled by default. When it is enabled, it will search for bugs that were created before the given date
 * created_since: optional, it is disabled by default. When it is enabled, it will search for bugs that were created since the given date
 * auto_mode: optional, it is disabled by default. When it is enabled, it will use the date_last_updated of bugs last time as the next modified_since.
 * failed_when_total_zero: it is disabled by default, When it is enabled, it will return failed when the total size is zero.
* parallel: optional, it is disabled by default. When it is enabled, it will use [GNU Parallel](https://www.gnu.org/software/parallel/).

```yaml
resources:
- name: bugs
  icon: bug-outline
  type: resource-launchpad-bug
  check_every: 10m
  source:
    id: 1
```
or
```yaml
resources:
- name: bugs
  icon: bug-outline
  type: resource-launchpad-bug
  check_every: 10m
  source:
    project: linux
    tag:
      - focal
      - apport-collected
    combinator: all
```
or
```yaml
resources:
- name: bugs
  icon: bug-outline
  type: resource-launchpad-bug
  check_every: 10m
  source:
    project: linux
    id:
      - 1
      - 10
      - 100
    tag:
      - focal
      - apport-collected
    combinator: all
```

### Example

```yaml
jobs:
- name: check-bugs
  plan:
  - get: bugs
    trigger: true
  - task: check
    config:
      platform: linux
      image_resource:
        type: registry-image
        source:
          repository: alpine
          tag: latest
      inputs:
        - name: bugs
      run:
        path: sh
        args:
        - -exc
        - |
          apk add jq
          for json in bugs/*.json; do
            echo "= $json ="
            id=$(jq -r .id < "$json")
            jq -r '"Title: " + .title + "\n" + .description' < "$json"
            jq -r '.entries | .[] | .bug_target_name + ": " + .status' < bugs/tasks/"$id".json
          done
```
