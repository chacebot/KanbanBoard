import express from "express";
import swaggerUi from "swagger-ui-express";
import { loadOpenApiSpec } from "./openapi";

export const app = express();
app.use(express.json());

const openApiSpec = loadOpenApiSpec();

app.get("/", (_req, res) => {
  res.json({ message: "KanbanBoard API is running" });
});

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.get("/openapi.json", (_req, res) => {
  res.json(openApiSpec);
});

app.use("/docs", swaggerUi.serve, swaggerUi.setup(openApiSpec));

