# docker-gitlab-ci-aws-bundler

We use this docker to build a website with Capistrano and to deploy it
to Amazon Beanstalk. It contains AWS CLI and some preinstalled gems for
capastrano.

Our gitlab-ci.yml looks like this:

```yaml
image: mipmip/gitlab-ci-aws-bundler
stages:
  - test
  - production

before_script:
  - bundle install
  - echo "[default]" >> /root/.aws/config
  - echo "region = eu-west-1" >> /root/.aws/config
  - echo "[default]" >> /root/.aws/credentials
  - echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" >>
    /root/.aws/credentials
  - echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >>
    /root/.aws/credentials
  - chmod 600 ~/.aws/credentials
  - echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
  - chmod 600 ~/.ssh/id_rsa
  - eb status -v myproject-production| grep InService | sed 's/^ *//;s/
    *$//' | cut -d":" -f1 > /root/instance.txt
  - aws ec2 describe-instances --instance-ids --query
    "Reservations[*].Instances[*].PublicIpAddress" --output=text `cat
/root/instance.txt` > /root/address.txt
  - ssh-keyscan -H `cat /root/address.txt`  >> /root/.ssh/known_hosts

test_aws:
  stage: test
  environment: testing
  script:
    - pwd
    - bundle exec cap beanstalktest eb_sync_n_deploy
  cache:
    paths:
      - vendor/
      - cap_eb_beanstalktest_build/
  only:
    - branches@mygroup/myproject
  except:
    - master@mygroup/myproject

deploy_to_production_after_merge:
  stage: production
  environment: production
  script:
    - bundle exec cap beanstalk eb_sync_n_deploy
  cache:
    paths:
      - vendor/
      - cap_eb_beanstalk_build/
  only:
    - master@mygroup/myproject
```
