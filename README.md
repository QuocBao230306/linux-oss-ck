# Smart Messenger — Linux & Open Source Software Final Project

Ứng dụng nhắn tin web thời gian thực, dùng React/Vite, Java Spring Boot, MySQL, WebSocket/STOMP và Nginx. Bộ triển khai Docker Compose được bổ sung để dễ trình bày các nội dung Linux/OSS: quản lý dịch vụ, cấu hình môi trường, log, volume, mạng container, backup/restore và reverse proxy.

## 1. Kiến trúc

```text
Browser :8088
   | HTTP / WebSocket
   v
Nginx (frontend container)
   |-- React/Vite static assets
   |-- /api/* ----------> Spring Boot :8080
   |-- /ws, /ws-native -> Spring WebSocket/STOMP
                            |
                            v
                       MySQL 8.4

Persistent volumes: mysql_data, messenger_uploads
```

| Thành phần | Công nghệ |
|---|---|
| OS demo | Ubuntu 22.04/24.04/26.04 (Docker Engine hỗ trợ) |
| Frontend | React 18, Vite, JavaScript, Tailwind CSS |
| Backend | Java 17, Spring Boot 3.2.4, REST API, WebSocket/STOMP |
| Database | MySQL 8.4 |
| Reverse proxy | Nginx (container) |
| Deployment | Docker Compose |


## 2. Chức năng hiện có

- Đăng nhập, đăng ký xác minh email, Google login (cần cấu hình OAuth/SMTP).
- Chat cá nhân và nhóm, nhắn tin realtime, trạng thái online, đang nhập, đã đọc.
- Tạo nhóm, quản lý thành viên/nhóm, đổi tên, phân quyền chủ nhóm.
- Sửa/xóa tin nhắn, trả lời, reaction, tìm tin nhắn.
- Gửi ảnh và file được hỗ trợ; lưu file upload theo conversation.
- Hồ sơ người dùng, avatar, trạng thái ngắn, đổi mật khẩu.
- Kết bạn, chặn, bảng tin cộng đồng, bình luận, like.
- Hồ sơ khám phá thành viên.
- Tích hợp AI chat, @AI, tóm tắt hội thoại (cần API key Groq).
- Trang quản trị: thống kê, quản lý người dùng, khóa tài khoản, xóa hội thoại.


## 3. Triển khai nhanh trên Ubuntu bằng Docker Compose (khuyến nghị cho demo)

### Yêu cầu

- Ubuntu và Docker Engine.
- Docker Compose plugin (`docker compose`).
- Git, openssl, Python 3.

### Cài Docker (nếu Ubuntu chưa có)

Trên Ubuntu, có thể cài gói Docker từ kho Ubuntu (tên gói Compose có thể khác tùy phiên bản):

```bash
sudo apt update
sudo apt install docker.io docker-compose-v2 openssl git python3
sudo systemctl enable --now docker
sudo docker --version
sudo docker compose version
```

Nếu `docker-compose-v2` không có trong kho của bản Ubuntu bạn dùng, cài Docker Engine và Compose plugin theo tài liệu chính thức Docker. Tránh cài đồng thời nhiều bản Docker khác nhau.


### Bước 1 — Lấy source

```bash
git clone https://github.com/deptraibanfifai/smart-messenger.git
cd smart-messenger
```

Nếu đã có source, chuyển vào đúng thư mục project, không clone lồng thêm.

### Bước 2 — Tạo file cấu hình và secrets

```bash
chmod +x scripts/setup-ubuntu.sh
./scripts/setup-ubuntu.sh
nano .env
```

Script tạo `.env` với mật khẩu MySQL và JWT secret ngẫu nhiên, đồng thời đặt quyền file `600`. Có thể chỉnh `APP_PORT` (mặc định `8088`). Nếu lệnh Docker báo permission denied, hãy cài Docker theo hướng dẫn Ubuntu và đăng nhập lại sau khi thêm user vào nhóm `docker` (hoặc dùng quyền sudo phù hợp). Các biến `GROQ_API_KEY`, SMTP và Google OAuth là tùy chọn, chỉ cần nếu demo tính năng tương ứng. Không đưa `.env` lên Git hoặc chia sẻ trong báo cáo.


### Bước 3 — Build và khởi chạy

```bash
docker compose up -d --build
```

Lần đầu build cần Internet để tải Maven/npm dependencies và Docker images. Kiểm tra:

```bash
docker compose ps
docker compose logs --tail=80 backend
docker compose logs --tail=40 frontend
docker compose logs --tail=40 mysql
```

Mở trình duyệt: **http://localhost:8088**. MySQL không được publish ra host; chỉ các container trong network Compose truy cập.

### Bước 4 — Đăng nhập demo

Database khởi tạo mới có 3 tài khoản:

| Role | Username | Password |
|---|---|---|
| Admin | `admin` | `password123` |
| User | `sinhvien1` | `password123` |
| User | `sinhvien2` | `password123` |

Tài khoản mẫu chỉ dành cho demo học tập. Thay mật khẩu nếu triển khai ngoài máy cá nhân. SQL init chỉ chạy khi volume database mới/đang rỗng; nếu đã có volume cũ thì dữ liệu seed không tự cập nhật.

### Bước 5 — Dừng và khởi động lại

```bash
docker compose stop
docker compose start
# hoặc dừng và xóa container/network (giữ dữ liệu trong volumes)
docker compose down
# khởi chạy lại
docker compose up -d
```

Không dùng `docker compose down -v` trừ khi chủ động muốn xóa toàn bộ database và file upload.


## 4. Backup / Restore

### Backup

```bash
chmod +x scripts/backup.sh
./scripts/backup.sh
ls -lh backups/
```
Script tạo bản nén SQL database và file uploads. Giữ backup ở nơi khác trước khi thao tác destructive.


### Restore database (cẩn trọng: ghi đè dữ liệu database)

Chọn file backup, thay `BACKUP_FILE` bên dưới:

```bash
BACKUP_FILE="backups/database-YYYYMMDD-HHMMSS.sql.gz"
gunzip -c "$BACKUP_FILE" | docker compose exec -T mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" smart_messenger_db'
```

Restore uploads (lệnh này ghi đè thư mục upload hiện có; backup trước):

```bash
UPLOAD_BACKUP="backups/uploads-YYYYMMDD-HHMMSS.tar.gz"
BACKEND="$(docker compose ps -q backend)"
docker exec -i "$BACKEND" sh -c 'cd /app && tar -xzf -' < "$UPLOAD_BACKUP"
```

Backup upload tar chứa thư mục `uploads`.


## 5. Kiểm tra nhanh trước khi demo

```bash
docker compose ps
docker compose exec mysql mysql -uroot -p -e "SHOW DATABASES; USE smart_messenger_db; SHOW TABLES;"
```

Thử các luồng:
1. Mở `http://localhost:8088` và đăng nhập `sinhvien1` ở cửa sổ thường.
2. Đăng nhập `sinhvien2` ở cửa sổ ẩn danh hoặc trình duyệt khác.
3. Gửi tin nhắn hai chiều, xác nhận nhận tin không cần refresh.
4. Tạo nhóm, thêm thành viên và gửi tin trong nhóm.
5. Kiểm tra ảnh/file, reaction, reply, tìm kiếm, trạng thái online.
6. Thử Community: tạo post, like, bình luận.
7. Đăng nhập Admin, kiểm tra thống kê và khóa/mở khóa tài khoản demo.
8. Nếu đã cấu hình Groq, thử AI chat và tóm tắt hội thoại.
9. Chạy backup script, xác nhận hai file backup được tạo.


## 6. Các lệnh Linux dùng để trình bày

```bash
# system information
uname -a
lsb_release -a
free -h
df -h

# Docker service and containers
sudo systemctl status docker
docker compose ps
docker stats

docker compose logs -f backend
# exit live logs with Ctrl+C

# Inspect network and ports
ip addr
ss -tulpn

docker network ls
docker volume ls
docker inspect smart-messenger-backend

# restart only a service
docker compose restart backend

# inspect project files and permissions
find . -maxdepth 2 -type f -print
ls -lah
```

Gợi ý trình bày các khái niệm: Linux terminal, quyền file, process/service, port, network bridge, container, volume, environment variable, log, reverse proxy, backup, mã nguồn mở và license.


## 7. Chạy chế độ developer (không dùng Compose frontend/backend)

Database vẫn có thể chạy bằng Docker; frontend/backend chạy trực tiếp trên Ubuntu.


### Database

```bash
docker compose up -d mysql
```

### Backend

Cài Java 17 và Maven. Trong terminal backend:

```bash
cd backend
export SPRING_DATASOURCE_URL='jdbc:mysql://localhost:3306/smart_messenger_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true'
export SPRING_DATASOURCE_USERNAME=root
set -a
source ../.env
set +a
export SPRING_DATASOURCE_PASSWORD="$MYSQL_ROOT_PASSWORD"
export JWT_SECRET="$(openssl rand -base64 48)"
mvn spring-boot:run
```

Nếu dùng database container đã tạo bởi Compose, mật khẩu lấy từ file `.env` (không commit file này). Backend chạy port `8080`.

### Frontend

```bash
cd frontend
npm ci
npm run dev
```
Mở `http://localhost:5173`. Vite proxy `/api` và WebSocket sang backend `localhost:8080`.


## 8. Troubleshooting

| Vấn đề | Cách kiểm tra / xử lý |
|---|---|
| Container build lỗi | `docker compose logs --tail=100 backend`; kiểm tra Internet, Java 17/Maven dependency và npm registry |
| MySQL chưa sẵn sàng | `docker compose logs mysql`; chờ healthcheck; `docker compose ps` |
| Không đăng nhập được tài khoản demo | Seed chỉ chạy trên volume database mới; hash demo được cập nhật trong init SQL; xem `users` table và logs backend |
| Chat realtime không hoạt động | Kiểm tra backend log, `/ws-native` proxy, hai user có cùng conversation/member hay không |
| Upload thất bại | Kiểm tra file type/size, giới hạn 20 MB, `docker compose logs backend` và volume upload |
| AI không phản hồi | Kiểm tra `GROQ_API_KEY`, `GROQ_MODEL`, mạng Internet và log backend; AI là dịch vụ ngoài, không phải chức năng offline |
| Port 8088 bị chiếm | Đổi `APP_PORT` trong `.env`, rồi `docker compose up -d` |
| Muốn reset dữ liệu | Backup trước; chỉ sau khi hiểu dữ liệu mất, chạy `docker compose down -v` |


## 9. Phạm vi và lưu ý bảo mật

- Đây là project demo học tập, không phải hệ thống production đã kiểm thử tải/penetration test.
- JWT, database password, SMTP credentials, AI API key phải nằm trong `.env` hoặc secret manager; không commit secrets.
- Cài đặt Compose publish web port; MySQL chỉ nằm trong network nội bộ Compose.
- Dữ liệu upload và database được lưu trong Docker volumes để tồn tại qua việc recreate container.
- Email verification cần SMTP; Google sign-in cần OAuth client; AI cần Groq API key.
- Backend dùng Hibernate `ddl-auto=update` cho demo; hệ thống production nên chuyển schema sang migrations có version, backup và review.
- Khi public ra Internet, cấu hình HTTPS, domain, rate limiting, giới hạn CORS/origin, backup ngoài máy và kiểm thử bảo mật trước.

## 10. License / OSS

Các dependency open-source được quản lý trong `backend/pom.xml` và `frontend/package.json` / `package-lock.json`. Trước khi phát hành hoặc nộp bản có yêu cầu license, hãy tạo danh sách license dependency (SBOM), lưu license của project/dependency và ghi nguồn các thành phần sử dụng. Kiểm tra license upstream của repository trước khi phân phối lại.

## 8. Ubuntu system administration extras (final-exam demo)

Scripts added for a Linux administration demo:

```bash
# Check host/container resource use and ports
./scripts/monitor.sh

# Install Compose stack as a systemd oneshot at boot (requires sudo)
sudo ./scripts/install-systemd.sh

# Daily backup at 02:00 via cron (requires sudo)
sudo apt install cron
sudo ./scripts/install-backup-cron.sh

# Database restore with confirmation prompt
./scripts/restore.sh backups/database-YYYYMMDD-HHMMSS.sql.gz
# Restore uploaded files (with pre-restore safety archive)
./scripts/restore-uploads.sh backups/uploads-YYYYMMDD-HHMMSS.tar.gz

# Controlled outage/recovery demonstration
./scripts/demo-failure.sh stop-backend
./scripts/demo-failure.sh recover
```

Read `SYSTEM_ADMINISTRATION.md` for monitoring, logs, failure demo, recovery, backup/restore, and Docker concepts. Read `OSS_DOCUMENTATION.md` for the open-source software inventory and license-audit checklist.
