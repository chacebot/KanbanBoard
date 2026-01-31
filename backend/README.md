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

2. Run the server:

```bash
npm run dev
```

3. Open the interactive API docs (Swagger UI):

- Swagger UI: `http://localhost:8000/docs`
- Raw OpenAPI JSON: `http://localhost:8000/openapi.json`

### Running Tests

From the `backend` directory:

```bash
npm test
```
