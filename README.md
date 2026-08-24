# Virtue Cleaning Solution

A containerized landing page for Virtue Cleaning Solution — built with Flask, deployed via Docker, backed by a PostgreSQL database for internal operations data (departments, staff, and supplies inventory).

![Flask](https://img.shields.io/badge/Flask-000000?logo=flask&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EC2-FF9900?logo=amazonaws&logoColor=white)

**Live:** http://44.200.8.247:8080

## Tagline
Clean spaces. Better places. Cleaning with integrity.

## Architecture

\`\`\`mermaid
graph LR
    A[Flask App :8080] -->|internal network| B[(PostgreSQL app-db)]
    A -->|serves| C[Public landing page]
\`\`\`

## What this includes
- **Flask app** (\`app.py\`) — serves the branded landing page
- **Dockerfile** — containerizes the app for deployment
- **PostgreSQL schema** (\`schema.sql\`) — departments, employees, and supplies inventory tables, running on an isolated internal Docker network (no public port exposed)

## Getting started

\`\`\`bash
docker build -t virtue-cleaning-image .
docker run -d -p 8080:80 --name virtue-cleaning virtue-cleaning-image
\`\`\`

## Tech stack
Flask · Docker · PostgreSQL · AWS EC2

## Author
Built by [Derick / SIM](https://github.com/UncleD0886475978)
