.DEFAULT_GOAL ?= help
.PHONY: help

help:
	@echo "${Project}"
	@echo "${Description}"
	@echo ""
	@echo "	deploy - deploy aws security survival kit templates"
	@echo "	---"
	@echo "	tear-down - destroy CloudFormation stacks"
	@echo "	clean - clean temp folders"

###################### Parameters ######################
AlarmRecipient ?= "rpgd60@yahoo.com"
Project ?= aws-security-survival-kit
Description ?= Bare minimum AWS Security alerting
LocalAWSRegion ?= eu-west-1
CTLogGroupName ?= "aws-cloudtrail-logs-245790757869-ef086394"
AwsCliProfile ?= "course"
#######################################################

deploy:
	aws cloudformation deploy \
		--template-file ./cfn-local.yml \
		--region ${LocalAWSRegion} \
		--stack-name "${Project}-local" \
		--parameter-overrides \
			Project=${Project} \
			AlarmRecipient=${AlarmRecipient} \
			CTLogGroupName=${CTLogGroupName} \
		--no-fail-on-empty-changeset \
		--profile "${AwsCliProfile}"

	aws cloudformation deploy \
		--template-file ./cfn-global.yml \
		--region us-east-1 \
		--stack-name "${Project}-global" \
		--parameter-overrides \
			Project=${Project} \
			AlarmRecipient=${AlarmRecipient} \
		--no-fail-on-empty-changeset \
		--profile "${AwsCliProfile}"
tear-down:
	@read -p "Are you sure that you want to destroy stack '${Project}'? [y/N]: " sure && [ $${sure:-N} = 'y' ]
	aws cloudformation delete-stack --region ${LocalAWSRegion} --stack-name "${Project}-local" --profile "${AwsCliProfile}"
	aws cloudformation delete-stack --region us-east-1 --stack-name "${Project}-global" --profile "${AwsCliProfile}"

clean:
	@rm -fr temp/
	@rm -fr dist/
	@rm -fr htmlcov/
	@rm -fr site/
	@rm -fr .eggs/
	@rm -fr .tox/
	@find . -name '*.egg-info' -exec rm -fr {} +
	@find . -name '.DS_Store' -exec rm -fr {} +
	@find . -name '*.egg' -exec rm -f {} +
	@find . -name '*.pyc' -exec rm -f {} +
	@find . -name '*.pyo' -exec rm -f {} +
	@find . -name '*~' -exec rm -f {} +
	@find . -name '__pycache__' -exec rm -fr {} +
