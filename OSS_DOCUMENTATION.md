# Open Source Software Documentation — Smart Messenger

## 1. Project components

| Component | Role | Source / license verification |
|---|---|---|
| Ubuntu Linux | Host operating system for demonstration | Verify the installed Ubuntu release and its license notices |
| Docker Engine / Compose | Container runtime and service orchestration | Docker documentation and license notices for installed packages |
| Java / Spring Boot | Backend runtime and web framework | Check exact dependency versions and license metadata in `backend/pom.xml` |
| React / Vite | Frontend UI and build tool | Check exact versions and license metadata in `frontend/package.json` and lock file |
| MySQL | Relational database | Consult MySQL 8.4 licensing and distribution terms for the deployment used |
| Nginx | Static web server and reverse proxy | Check Nginx distribution/version and license notices |


## 2. License audit notes

This document is an inventory starting point, not legal advice and not a substitute for a dependency-level license scan. The project must not claim every dependency is OSS-compatible until all direct and transitive dependencies, fonts, icons, images, and other assets have been reviewed. Record the exact version, license, source URL, and any attribution requirement for each dependency in the final report.


## 3. Recommended evidence for the course

- Show project repository and meaningful commit history.
- Show dependency manifests and lock files.
- Explain why each major component is used.
- Keep upstream copyright and license notices intact.
- Do not redistribute API keys, `.env`, user uploads, or database dumps.

