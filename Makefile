STACK_NAME := swarm-monitoring
DEPLOY_PATH := /opt/monitoring

.PHONY: deploy remove status logs-prometheus logs-grafana ps sync

# Синхронизировать конфиги на VPS и задеплоить стек
deploy: sync
	docker stack deploy -c docker-stack.yml --with-registry-auth $(STACK_NAME)

# Только синхронизировать файлы (если деплоишь с локальной машины через SSH)
sync:
	ssh $${VPS_HOST} "mkdir -p $(DEPLOY_PATH)/grafana/provisioning/datasources $(DEPLOY_PATH)/grafana/provisioning/dashboards $(DEPLOY_PATH)/prometheus"
	rsync -avz --exclude='.git' --exclude='.idea' . $${VPS_HOST}:$(DEPLOY_PATH)/
	ssh $${VPS_HOST} "cd $(DEPLOY_PATH) && docker config rm monitoring_prometheus_config 2>/dev/null || true"

# Деплой напрямую на VPS (запускать там)
deploy-local:
	docker stack deploy -c docker-stack.yml $(STACK_NAME)

remove:
	docker stack rm $(STACK_NAME)

status:
	docker stack services $(STACK_NAME)

ps:
	docker stack ps $(STACK_NAME) --no-trunc

logs-%:
	docker service logs $(STACK_NAME)_$* -f --tail=100
