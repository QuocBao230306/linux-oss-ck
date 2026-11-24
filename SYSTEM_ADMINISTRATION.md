# Ubuntu Administration, Monitoring, Failure Demo, and Recovery

## Install/start on boot

After the stack is running and `.env` has been reviewed:

```bash
sudo ./scripts/install-systemd.sh
sudo systemctl status smart-messenger.service
```

The unit runs Docker Compose at boot and stops the stack on system shutdown. To remove autostart:

```bash
sudo systemctl disable --now smart-messenger.service
sudo rm -f /etc/systemd/system/smart-messenger.service
sudo systemctl daemon-reload
```

## Monitoring snapshot

```bash
./scripts/monitor.sh
```

For continuous container metrics, use:

```bash
docker stats
```

## Log troubleshooting

```bash
docker compose logs --tail=100 mysql
docker compose logs --tail=100 backend
docker compose logs --tail=100 frontend
# Follow one service live:
docker compose logs -f backend
```

## Demonstrate a backend outage and recovery (demo only)

This intentionally stops the backend; only use during presentation when no one needs the chat:

```bash
./scripts/demo-failure.sh stop-backend
# show browser failure and service status
./scripts/monitor.sh
# restore service
./scripts/demo-failure.sh recover
```

## Backup and restore

```bash
./scripts/backup.sh
ls -lh backups/
sha256sum -c backups/checksum-YYYYMMDD-HHMMSS.sha256
./scripts/restore.sh backups/database-YYYYMMDD-HHMMSS.sql.gz
```
Restore requires typing `RESTORE` and overwrites database content. Back up current data first. Uploads backup is created separately; restoring uploads overwrites files in the backend upload directory and should be done only after taking a safety copy.


## Docker concepts to demonstrate

- **Container:** isolated runtime for MySQL, Spring Boot and frontend/Nginx.
- **Compose:** declarative service orchestration.
- **Bridge network:** internal service-to-service communication by Compose service name.
- **Volume:** persistence independent of container lifecycle.
- **Health check:** service readiness signal; it is not a complete application test.
- **Restart policy:** automatically restart a container after an abnormal exit.
- **Reverse proxy:** Nginx serves frontend and routes API/WebSocket requests.

## Schedule automatic backup (daily 02:00)

```bash
sudo apt update
sudo apt install cron
sudo ./scripts/install-backup-cron.sh
sudo cat /etc/cron.d/smart-messenger-backup
```

Remove the schedule when no longer needed:

```bash
sudo rm -f /etc/cron.d/smart-messenger-backup
```

Restore upload files (overwrites current uploads, creates a pre-restore copy first):

```bash
./scripts/restore-uploads.sh backups/uploads-YYYYMMDD-HHMMSS.tar.gz
```
