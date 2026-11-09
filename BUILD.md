# virtue-cleaning-solution — Build Notes

## One-line install (fresh Ubuntu/Debian VM)

```bash
curl -fsSL https://raw.githubusercontent.com/UncleD0886475978/virtue-cleaning-solution/main/setup.sh | bash
```

The script installs its own prerequisites (git, curl, and Docker) via apt/official sources, then builds and runs the Flask app with plain `docker build`/`docker run -p 8080:80` (no compose file in this repo).

Alternative — clone and run:

```bash
git clone https://github.com/UncleD0886475978/virtue-cleaning-solution.git
cd virtue-cleaning-solution && ./setup.sh
```

- **Repo:** https://github.com/UncleD0886475978/virtue-cleaning-solution
- **Public status:** Public (contents listed and raw files fetched via the GitHub connector without restriction).
- **Stack actually found:** Python Flask + Docker. Proof: `app.py` (Flask app, single `/` route rendering `index.html`, `app.run(host="0.0.0.0", port=80)`), `Dockerfile` (`FROM python:3.12-slim`, `RUN pip install flask`, `EXPOSE 80`, `CMD ["python", "app.py"]`), `templates/` and `static/` folders, `schema.sql` (PostgreSQL tables for departments/employees/supplies). **Not present:** no `docker-compose.yml` and no `requirements.txt` in the root listing — the README's own run command is `docker build` + `docker run -d -p 8080:80`. PostgreSQL is schema-only in the repo; no database container is defined.
- **What setup.sh does:** Bootstraps git/curl and Docker, finds or clones the repo, builds the image with plain `docker build` (since there is no compose file), replaces any old `virtue-cleaning` container, runs it as `-p 8080:80`, waits for http://localhost:8080 to respond, and prints the URL plus stop/start/logs commands.
- **Issue it prevents:** Guessing the port or hunting for a compose file that doesn't exist — the app listens on 80 inside the container and is published on 8080, exactly as the README/Dockerfile define.
