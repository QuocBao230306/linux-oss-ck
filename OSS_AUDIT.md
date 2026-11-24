# Open Source / Linux deployment audit

## Project inventory
- Frontend: React, React DOM, React Router, Vite, STOMP client, Axios, Tailwind CSS, Lucide.
- Backend: Java 17, Spring Boot, Spring Security, Spring Data JPA, Spring WebSocket, JJWT, Lombok, MySQL Connector.
- Infrastructure: Ubuntu, Docker Engine, Docker Compose, MySQL 8.4, Nginx.

Dependency versions are managed by `frontend/package-lock.json` and Maven's `backend/pom.xml` (some backend versions are inherited from Spring Boot's BOM).

## Improvements included in this review
- Added a Docker Compose deployment for MySQL, Spring Boot and Nginx/React.
- MySQL is no longer published to a host port in the Compose deployment; it is only available on the internal Compose network.
- Added named persistent volumes for database and uploaded files.
- Added environment-variable configuration for the database password, JWT secret, SMTP, Google OAuth, Groq AI and upload directory.
- Added Ubuntu setup script that creates `.env` with generated database/JWT secrets and restrictive file permissions.
- Added database and upload backup script.
- Added Nginx reverse proxy routes for REST and STOMP/WebSocket.
- Updated the seeded BCrypt hash and verified the demo password against the hash with `htpasswd`'s BCrypt verification.
- Added exam/demo checklist and Linux command list.

## Remaining issues / risk
1. **Build/runtime verification:** Maven, Docker and network dependency downloads were not available in the review environment. The frontend test/build could not run because packages were missing. Build and integration tests must be run on Ubuntu with Docker/network before the exam.
2. **License:** No project `LICENSE` file was found in the supplied archive. Confirm the original repository's license and retain notices before redistributing. Do not label the code as MIT/GPL/etc. without verification.
3. **Production readiness:** No formal penetration test, load test, rate-limit review or security audit has been performed. Demo accounts use a known password.
4. **Schema evolution:** Hibernate `ddl-auto=update` is convenient for a classroom demo. Use versioned migrations and review migration scripts before production.
5. **Email/Google/AI:** These integrations require external credentials and were not verified here. Core login/chat demo can be tested separately.
6. **Browser security:** JWT is stored in browser local storage; protect against XSS, use HTTPS when exposed beyond localhost, and review token lifecycle/expiry.
7. **Data backup:** Backup script creates local database/upload archives only. Copy backups to another disk/location and test restore before relying on them.
8. **Admin demo:** Do not expose seeded admin credentials to a public host; replace them before any non-local deployment.

## Verification performed during archive review
- Archive extraction and source inventory.
- Static review of Spring Security/JWT, REST controllers, file upload paths, configuration, SQL schema and frontend services.
- Bash syntax validation for project shell scripts.
- BCrypt format/password check for seeded demo password.
- Frontend unit tests/build attempted but blocked by missing npm dependencies and install timeout.
- Backend Maven test attempted but Maven is not installed in the review environment.
- Docker Compose validation/build was not possible because Docker is not installed in the review environment.
