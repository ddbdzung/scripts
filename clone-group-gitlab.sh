#!/bin/bash
# Author: David Dang (https://github.com/ddbdzung)
# Presequisites: git, curl, jq, generated SSH key

# Clone a group of GitLab repositories
# Usage: bash clone-group-gitlab.sh

echo "Type your GitLab group id:"
read group_id
echo "Type your GitLab access token:"
read access_token
for repo in $(curl -s --header "PRIVATE-TOKEN: $access_token" https://gitlab.com/api/v4/groups/$group_id | jq -r ".projects[].ssh_url_to_repo"); do git clone $repo; done;
