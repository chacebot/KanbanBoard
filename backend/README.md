## KanbanBoard Backend (API)

This directory contains a lightweight REST API backend for KanbanBoard, designed to:

- Provide a JSON REST API for boards, columns, and cards
- Expose a first-class OpenAPI specification with Swagger UI
- Run comfortably on a no-cost/free-tier hosting provider

### Tech Stack

- **Node.js 20+**
- **TypeScript**
- **Express** for the web framework
- **Swagger UI** for interactive OpenAPI exploration
- **Vitest + Supertest** for automated tests

### Local Setup

1. Install dependencies:

```bash
cd backend
npm install
```

2. Configure environment variables:

```bash
export DATABASE_URL="postgres://user:pass@host:5432/kanban"
export AUTH_ISSUER="https://your-auth-provider/"
export AUTH_AUDIENCE="your-api-audience"
export AUTH_JWKS_URL="https://your-auth-provider/.well-known/jwks.json"
```

For local development only, you can bypass auth with:

```bash
export AUTH_DISABLED="true"
export AUTH_DEV_USER_ID="dev-user"
```

3. Run migrations:

```bash
psql "$DATABASE_URL" -f migrations/001_init.sql
```

4. Run the server:

```bash
npm run dev
```

3. Open the interactive API docs (Swagger UI):

- Swagger UI: `http://localhost:8000/docs`
- Raw OpenAPI JSON: `http://localhost:8000/openapi.json`

### Running Tests

Tests require a dedicated Postgres database. Set `TEST_DATABASE_URL` before running:

```bash
export TEST_DATABASE_URL="postgres://user:pass@host:5432/kanban_test"
npm test
```

### Docker Compose (local Postgres + API)

From the repository root:

```bash
docker compose up --build
```

The API will be available at `http://localhost:8000`, and Postgres at `localhost:5432`.

After the containers start, run migrations once:

```bash
docker exec -it kanban-postgres psql -U kanban -d kanban -f /migrations/001_init.sql
```

Note: The API container uses `AUTH_DISABLED=true` for local dev. Swap to real auth
env vars for production.
