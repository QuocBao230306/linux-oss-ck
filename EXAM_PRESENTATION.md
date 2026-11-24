# Kịch bản trình bày Smart Messenger — Linux & OSS

## Mục tiêu demo (khoảng 8–12 phút)
1. Giới thiệu bài toán: nhắn tin realtime, nhóm, hồ sơ, community và AI hỗ trợ.
2. Giới thiệu stack và kiến trúc: React, Spring Boot, MySQL, WebSocket/STOMP, Docker Compose, Nginx.
3. Trình bày triển khai trên Ubuntu: terminal, source tree, `.env`, Docker Compose.
4. Chạy `docker compose up -d --build`, đọc `docker compose ps` và logs.
5. Mở web, đăng nhập hai tài khoản, chat realtime; demo nhóm/file/Community.
6. Đăng nhập admin, trình bày thống kê và chức năng quản trị.
7. Trình bày Docker network/volumes, MySQL không publish port, uploads/database persistent.
8. Thực hiện backup và chỉ ra file backup tạo ra.
9. Nêu hạn chế, hướng phát triển, license và dependency OSS.

## Danh sách ảnh minh chứng đề xuất
- `01-ubuntu-system.png`: thông tin Ubuntu (`uname -a`, `lsb_release -a`).
- `02-project-structure.png`: cây thư mục source.
- `03-env-config.png`: `.env.example` (không chụp secrets trong `.env`).
- `04-compose-running.png`: `docker compose ps`.
- `05-container-logs.png`: log backend/mysql (che thông tin nhạy cảm nếu có).
- `06-login.png`: màn hình login.
- `07-realtime-chat.png`: chat realtime giữa hai tài khoản.
- `08-group-chat.png`: nhóm chat.
- `09-community.png`: community post/comment/like.
- `10-admin-dashboard.png`: trang admin.
- `11-docker-volumes-network.png`: `docker volume ls`, `docker network ls`.
- `12-backup-files.png`: backup script và file backup.

## Lệnh Linux cần giải thích khi bảo vệ
```bash
pwd
ls -la
find . -maxdepth 2 -type f
chmod +x scripts/setup-ubuntu.sh scripts/backup.sh
./scripts/setup-ubuntu.sh
docker compose up -d --build
docker compose ps
docker compose logs -f backend
docker stats
ss -tulpn
docker network ls
docker volume ls
./scripts/backup.sh
docker compose stop
docker compose start
```

Có thể giải thích `chmod`, process/service, port, bridge network, volume, environment variables, reverse proxy, log, backup và open-source dependencies. Không cần đưa secrets lên slide/chụp ảnh.
