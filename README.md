# Django Starter Template Documentation

Welcome to the **Django Starter** project, a modern Django setup based on `cookiecutter-django`, configured with production-ready defaults and dev tooling for seamless development, testing, and deployment.

---

## 🚀 Getting Started

This template assumes you have already used `cookiecutter` to generate your project using `cookiecutter https://github.com/cookiecutter/cookiecutter-django`.

Once your project is cloned, follow the instructions below to configure and run the application.

---

## 🔧 Initial Setup After Cloning

### 1. Create Virtual Environment

```bash
python -m venv .venv
source .venv/bin/activate
```

### 2. Install `uv` and Project Dependencies

```bash
pip install uv
uv pip install --system --upgrade --all-extras
```

> This will install all packages including dev tools and extras like PostgreSQL, Redis, Celery, etc.

### 3. Install Node.js Dependencies

```bash
npm install
npm cache clean --force
```

---

## 🧪 Running the Project

### Run Dev Server (Backend)

```bash
hatch run dev-backend runserver
```

### Run Frontend (npm & webpack)

```bash
hatch run install
hatch run dev-frontend
```

### Run Production Server

```bash
hatch run prod-backend runserver
hatch run prod-frontend
```

> You can use `{args}` to pass custom manage.py commands like `migrate`, `shell`, etc.

---

## 🐳 Docker Setup (Updated)

### Start Docker Containers (Dev)

```bash
docker compose -f docker-compose.local.yml up
```

### Custom `uv` Integration with Docker

&#x20;updated container setup uses `uv` for isolated, fast dependency management. It ensures consistent environments for development and CI/CD.

---

## 🧰 Tooling Summary

| Tool           | Purpose                                    |
| -------------- | ------------------------------------------ |
| **hatch**      | Commands management                        |
| **uv**         | Fast dependency management, ENV management |
| **pre-commit** | Git hook formatting and linting            |
| **pytest**     | Testing framework                          |
| **ruff**       | Python linter and formatter                |
| **mypy**       | Static type checking                       |
| **djlint**     | Django template formatter and linter.      |

## 📌 Notes

* Use `hatch` to simplify all Python command tasks
* Use `uv` instead of `pip` for dependency control and speed
* To Avoid managing environments manually—`hatch` and `uv` take care of that

---

## 📬 Author

**Mahmoud Ezzat Moustafa**
📧 [Mahmoud.Ezzat.Moustafa@Gmail.com](mailto:Mahmoud.Ezzat.Moustafa@Gmail.com)

License: MIT OR GPL-2.0-or-later OR (FSFUL AND BSD-2-Clause)

---

Enjoy building with Django! 🛠️
