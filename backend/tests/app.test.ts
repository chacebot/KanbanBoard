import request from "supertest";
import { describe, it, expect } from "vitest";
import { app } from "../src/app";

describe("KanbanBoard API", () => {
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
  });
});

