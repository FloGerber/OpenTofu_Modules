#!/bin/bash

COMMAND=$(bundle exec terraspace all validate 2>&1 | grep "# batch" | awk '{$1=$1};1'| cut -d " " -f 3,6 )
COUNT=$(echo "$COMMAND" | awk -F" " 'BEGIN{max=0}{if(($2)>max) max=$2}END {print max}')

for ((x = 1; x <= COUNT; x++)); do

if [[ $x = 1 ]]
then
cat <<- EOF >>generated-ci-apply.yml
stages:
  - apply_batch_$x

.cache: &global_cache
  key: "Terraspace_cache"
  paths:
    - .terraspace-cache/$1/

EOF
else
sed -i "/^stages:/a\  - apply_batch_$x" generated-ci-apply.yml
fi


for STACK in $(echo "$COMMAND" | grep $x | cut -d " " -f 1 | xargs); do

cat <<- EOF >>generated-ci-apply.yml
apply_${STACK}:
  stage: apply_batch_$x
  when: manual
  script:
    - bundle exec terraspace up ${STACK} -y
  environment:
    name: $1
  cache:
    <<: *global_cache
  artifacts:
    when: always
    untracked: false
    expire_in: 5 days
    paths:
    - log/up/${STACK}.log

EOF
done

done
