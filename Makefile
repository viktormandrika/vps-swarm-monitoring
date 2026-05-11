STACK_NAME := swarm-monitoring
DEPLOY_PATH := /opt/monitoring

.PHONY: deploy remove status logs-prometheus logs-grafana logs-postgres-exporter ps sync update-postgres-monitoring

deploy:
	docker stack deploy -c docker-stack.yml $(STACK_NAME)

remove:
	docker stack rm $(STACK_NAME)

status:
	docker stack services $(STACK_NAME)

ps:
	docker stack ps $(STACK_NAME) --no-trunc

logs-%:
	docker service logs $(STACK_NAME)_$* -f --tail=100

update-postgres-monitoring:
	./scripts/update-postgres-monitoring.sh
