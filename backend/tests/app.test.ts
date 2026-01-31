import fs from "node:fs";
import path from "node:path";
import type { Express } from "express";
import { Pool } from "pg";
import request from "supertest";
import { afterAll, beforeAll, beforeEach, describe, it, expect } from "vitest";

const testDatabaseUrl = process.env.TEST_DATABASE_URL;
const describeDb = testDatabaseUrl ? describe : describe.skip;

describeDb("KanbanBoard API", () => {
  let app: Express;
  let pool: Pool;
  let closePool: (() => Promise<void>) | null = null;

  beforeAll(async () => {
    process.env.AUTH_DISABLED = "true";
    process.env.AUTH_DEV_USER_ID = "test-user";
    process.env.DATABASE_URL = testDatabaseUrl;

    pool = new Pool({ connectionString: testDatabaseUrl });
    const migrationsPath = path.join(
      __dirname,
      "..",
      "migrations",
      "001_init.sql",
    );
    const migrationSql = fs.readFileSync(migrationsPath, "utf8");
    const statements = migrationSql
      .split(";")
      .map((statement) => statement.trim())
      .filter((statement) => statement.length > 0);

    for (const statement of statements) {
      await pool.query(statement);
    }

    const appModule = await import("../src/app");
    const dbModule = await import("../src/db");
    app = appModule.app as Express;
    closePool = dbModule.closePool as () => Promise<void>;
  });

  beforeEach(async () => {
    await pool.query("TRUNCATE cards, columns, boards, users RESTART IDENTITY CASCADE");
  });

  afterAll(async () => {
    await pool.end();
    if (closePool) {
      await closePool();
    }
  });

  it("returns a root message", async () => {
    const response = await request(app).get("/");

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ message: "KanbanBoard API is running" });
  });

  it("returns health status", async () => {
    const response = await request(app).get("/health");

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: "ok" });
  });

  it("serves OpenAPI JSON", async () => {
    const response = await request(app).get("/openapi.json");

    expect(response.status).toBe(200);
    expect(response.body.openapi).toBe("3.0.3");
    expect(response.body.paths).toHaveProperty("/");
    expect(response.body.paths).toHaveProperty("/health");
    expect(response.body.paths).toHaveProperty("/boards");
    expect(response.body.paths).toHaveProperty("/columns");
    expect(response.body.paths).toHaveProperty("/cards");
    expect(response.body.paths).toHaveProperty("/sync/boards");
    expect(response.body.paths).toHaveProperty("/sync/columns");
    expect(response.body.paths).toHaveProperty("/sync/cards");
  });

  it("creates board, column, and card", async () => {
    const boardResponse = await request(app).post("/boards").send({
      title: "Personal Board",
    });

    expect(boardResponse.status).toBe(201);
    const boardId = boardResponse.body.id as string;

    const columnResponse = await request(app).post("/columns").send({
      boardId,
      title: "To Do",
      position: 0,
    });

    expect(columnResponse.status).toBe(201);
    const columnId = columnResponse.body.id as string;

    const cardResponse = await request(app).post("/cards").send({
      columnId,
      title: "Draft roadmap",
      description: "Outline Q2 initiatives.",
      position: 0,
    });

    expect(cardResponse.status).toBe(201);
    expect(cardResponse.body.columnId).toBe(columnId);
  });

  it("lists columns and cards by parent", async () => {
    const boardResponse = await request(app).post("/boards").send({
      title: "Work Board",
    });
    const boardId = boardResponse.body.id as string;

    const columnResponse = await request(app).post("/columns").send({
      boardId,
      title: "In Progress",
      position: 1,
    });
    const columnId = columnResponse.body.id as string;

    await request(app).post("/cards").send({
      columnId,
      title: "Refactor API",
      description: null,
      position: 0,
    });

    const columnsResponse = await request(app).get(`/boards/${boardId}/columns`);
    expect(columnsResponse.status).toBe(200);
    expect(columnsResponse.body.items).toHaveLength(1);

    const cardsResponse = await request(app).get(`/columns/${columnId}/cards`);
    expect(cardsResponse.status).toBe(200);
    expect(cardsResponse.body.items).toHaveLength(1);
  });

  it("syncs boards, columns, and cards", async () => {
    const boardSync = await request(app).post("/sync/boards").send({
      items: [{ title: "Sync Board" }],
    });

    expect(boardSync.status).toBe(201);
    const boardId = boardSync.body.items[0].id as string;

    const columnSync = await request(app).post("/sync/columns").send({
      items: [{ boardId, title: "Backlog", position: 0 }],
    });

    expect(columnSync.status).toBe(201);
    const columnId = columnSync.body.items[0].id as string;

    const cardSync = await request(app).post("/sync/cards").send({
      items: [
        {
          columnId,
          title: "Sync Card",
          description: null,
          position: 0,
        },
      ],
    });

    expect(cardSync.status).toBe(201);

    const boardRead = await request(app).get("/sync/boards?since=2000-01-01");
    expect(boardRead.status).toBe(200);
    expect(boardRead.body.items.length).toBeGreaterThan(0);
  });
});

