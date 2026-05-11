# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Docker Swarm monitoring stack for a single-node VPS. Collects and visualizes resource usage per service/container.

## Stack

| Service | Image | Role |
|---|---|---|
| Prometheus | `prom/prometheus` | Scrapes and stores metrics |
| Grafana | `grafana/grafana` | Dashboards and visualization |
| cAdvisor | `gcr.io/cadvisor/cadvisor` | Per-container CPU/RAM/net metrics |
| Node Exporter | `prom/node-exporter` | Host-level metrics |

## Commands

Deploy stack directly on VPS:
```bash
docker stack deploy -c docker-stack.yml monitoring
```

Status and logs:
```bash
docker stack services monitoring
docker stack ps monitoring
docker service logs monitoring_grafana -f
```

Remove stack:
```bash
docker stack rm monitoring
```

## Architecture

- `docker-stack.yml` — main stack definition with resource limits and placement constraints
- `prometheus/prometheus.yml` — referenced as a Docker config (`configs:` section); auto-mounted into the Prometheus container
- `grafana/provisioning/` — bind-mounted from `/opt/monitoring/grafana/provisioning` on the host; auto-provisions Prometheus datasource

**Service discovery:** Prometheus uses Swarm DNS `tasks.<service>` to discover all global-mode replicas. cAdvisor and node_exporter run in `global` mode (one per node).

**Placement:** Prometheus and Grafana are pinned to manager nodes. cAdvisor and node_exporter deploy globally (all nodes).

## Deployment path on VPS

All files should live at `/opt/monitoring/` on the VPS host.
Grafana provisioning is bind-mounted from `/opt/monitoring/grafana/provisioning`.

## Grafana dashboards to import

Import from grafana.com after first deploy:
- **1860** — Node Exporter Full (host CPU, RAM, disk, network)
- **193** — Docker monitoring (container metrics via cAdvisor)
