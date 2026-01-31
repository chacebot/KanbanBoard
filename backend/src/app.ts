import express from "express";
import swaggerUi from "swagger-ui-express";
import { requireAuth, type AuthenticatedRequest } from "./auth";
import {
  createBoard,
  createBoardsBulk,
  createCard,
  createCardsBulk,
  createColumn,
  createColumnsBulk,
  getBoardById,
  getCardById,
  getColumnById,
  listBoards,
  listBoardsSince,
  listCards,
  listCardsSince,
  listColumns,
  listColumnsSince,
  type BoardInput,
  type CardInput,
  type ColumnInput,
} from "./db";
import { loadOpenApiSpec } from "./openapi";

export const app = express();
app.use(express.json());

const openApiSpec = loadOpenApiSpec();

type BoardCreateResult =
  | { ok: true; input: BoardInput }
  | { ok: false; error: string };

type ColumnCreateResult =
  | { ok: true; input: ColumnInput }
  | { ok: false; error: string };

type CardCreateResult =
  | { ok: true; input: CardInput }
  | { ok: false; error: string };

type DateParseResult = { ok: true; date: Date } | { ok: false; error: string };

type OptionalDateParseResult =
  | { ok: true; date: Date | null }
  | { ok: false; error: string };

function normalizeDateString(value: string): string {
  return /^\d{4}-\d{2}-\d{2}$/.test(value) ? `${value}T00:00:00.000Z` : value;
}

function parseDateString(value: string): Date | null {
  const normalized = normalizeDateString(value);
  const parsed = new Date(normalized);
  if (Number.isNaN(parsed.getTime())) {
    return null;
  }
  return parsed;
}

function parseOptionalDateParam(dateParam: unknown): OptionalDateParseResult {
  if (dateParam === undefined) {
    return { ok: true, date: null };
  }

  if (typeof dateParam !== "string") {
    return { ok: false, error: "Invalid date parameter." };
  }

  const parsed = parseDateString(dateParam);
  if (!parsed) {
    return { ok: false, error: "Invalid date parameter." };
  }

  return { ok: true, date: parsed };
}

function createBoardFromPayload(payload: unknown): BoardCreateResult {
  const { title } = (payload ?? {}) as Record<string, unknown>;

  if (typeof title !== "string") {
    return { ok: false, error: "Invalid payload. Expecting title." };
  }

  return { ok: true, input: { title } };
}

function createColumnFromPayload(payload: unknown): ColumnCreateResult {
  const { boardId, title, position } = (payload ?? {}) as Record<
    string,
    unknown
  >;

  if (
    typeof boardId !== "string" ||
    typeof title !== "string" ||
    typeof position !== "number"
  ) {
    return {
      ok: false,
      error: "Invalid payload. Expecting boardId, title, position.",
    };
  }

  return { ok: true, input: { boardId, title, position } };
}

function createCardFromPayload(payload: unknown): CardCreateResult {
  const { columnId, title, description, position } = (payload ?? {}) as Record<
    string,
    unknown
  >;

  const descriptionValue =
    typeof description === "string" || description == null ? description : undefined;

  if (
    typeof columnId !== "string" ||
    typeof title !== "string" ||
    typeof position !== "number" ||
    descriptionValue === undefined
  ) {
    return {
      ok: false,
      error: "Invalid payload. Expecting columnId, title, description, position.",
    };
  }

  return {
    ok: true,
    input: {
      columnId,
      title,
      description: descriptionValue ?? null,
      position,
    },
  };
}

app.get("/", (_req, res) => {
  res.json({ message: "KanbanBoard API is running" });
});

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

app.get("/openapi.json", (_req, res) => {
  res.json(openApiSpec);
});

app.use("/boards", requireAuth);
app.use("/columns", requireAuth);
app.use("/cards", requireAuth);
app.use("/sync", requireAuth);

app.get("/boards", async (req, res) => {
  try {
    const items = await listBoards((req as AuthenticatedRequest).user.id);
    res.json({ items });
  } catch (error) {
    res.status(500).json({ error: "Failed to load boards." });
  }
});

app.post("/boards", async (req, res) => {
  const result = createBoardFromPayload(req.body);

  if (!result.ok) {
    return res.status(400).json({ error: result.error });
  }

  try {
    const board = await createBoard((req as AuthenticatedRequest).user.id, result.input);
    return res.status(201).json(board);
  } catch (error) {
    return res.status(500).json({ error: "Failed to create board." });
  }
});

app.get("/boards/:id", async (req, res) => {
  try {
    const board = await getBoardById(
      (req as AuthenticatedRequest).user.id,
      req.params.id,
    );

    if (!board) {
      return res.status(404).json({ error: "Board not found." });
    }

    return res.json(board);
  } catch (error) {
    return res.status(500).json({ error: "Failed to load board." });
  }
});

app.get("/boards/:id/columns", async (req, res) => {
  try {
    const items = await listColumns(
      (req as AuthenticatedRequest).user.id,
      req.params.id,
    );
    return res.json({ items });
  } catch (error) {
    return res.status(500).json({ error: "Failed to load columns." });
  }
});

app.post("/columns", async (req, res) => {
  const result = createColumnFromPayload(req.body);

  if (!result.ok) {
    return res.status(400).json({ error: result.error });
  }

  try {
    const column = await createColumn(
      (req as AuthenticatedRequest).user.id,
      result.input,
    );
    return res.status(201).json(column);
  } catch (error) {
    return res.status(500).json({ error: "Failed to create column." });
  }
});

app.get("/columns/:id", async (req, res) => {
  try {
    const column = await getColumnById(
      (req as AuthenticatedRequest).user.id,
      req.params.id,
    );

    if (!column) {
      return res.status(404).json({ error: "Column not found." });
    }

    return res.json(column);
  } catch (error) {
    return res.status(500).json({ error: "Failed to load column." });
  }
});

app.get("/columns/:id/cards", async (req, res) => {
  try {
    const items = await listCards(
      (req as AuthenticatedRequest).user.id,
      req.params.id,
    );
    return res.json({ items });
  } catch (error) {
    return res.status(500).json({ error: "Failed to load cards." });
  }
});

app.post("/cards", async (req, res) => {
  const result = createCardFromPayload(req.body);

  if (!result.ok) {
    return res.status(400).json({ error: result.error });
  }

  try {
    const card = await createCard(
      (req as AuthenticatedRequest).user.id,
      result.input,
    );
    return res.status(201).json(card);
  } catch (error) {
    return res.status(500).json({ error: "Failed to create card." });
  }
});

app.get("/cards/:id", async (req, res) => {
  try {
    const card = await getCardById(
      (req as AuthenticatedRequest).user.id,
      req.params.id,
    );

    if (!card) {
      return res.status(404).json({ error: "Card not found." });
    }

    return res.json(card);
  } catch (error) {
    return res.status(500).json({ error: "Failed to load card." });
  }
});

app.post("/sync/boards", async (req, res) => {
  const items = Array.isArray(req.body?.items) ? req.body.items : null;

  if (!items) {
    return res.status(400).json({ error: "Invalid payload. Expecting items array." });
  }

  const inputs: BoardInput[] = [];
  for (const entry of items) {
    const result = createBoardFromPayload(entry);
    if (!result.ok) {
      return res.status(400).json({ error: result.error });
    }
    inputs.push(result.input);
  }

  try {
    const created = await createBoardsBulk(
      (req as AuthenticatedRequest).user.id,
      inputs,
    );
    return res.status(201).json({ items: created });
  } catch (error) {
    return res.status(500).json({ error: "Failed to sync boards." });
  }
});

app.get("/sync/boards", async (req, res) => {
  const parsed = parseOptionalDateParam(req.query.since);

  if (!parsed.ok) {
    return res.status(400).json({ error: parsed.error });
  }

  try {
    const items = await listBoardsSince(
      (req as AuthenticatedRequest).user.id,
      parsed.date,
    );
    return res.json({ items });
  } catch (error) {
    return res.status(500).json({ error: "Failed to sync boards." });
  }
});

app.post("/sync/columns", async (req, res) => {
  const items = Array.isArray(req.body?.items) ? req.body.items : null;

  if (!items) {
    return res.status(400).json({ error: "Invalid payload. Expecting items array." });
  }

  const inputs: ColumnInput[] = [];
  for (const entry of items) {
    const result = createColumnFromPayload(entry);
    if (!result.ok) {
      return res.status(400).json({ error: result.error });
    }
    inputs.push(result.input);
  }

  try {
    const created = await createColumnsBulk(
      (req as AuthenticatedRequest).user.id,
      inputs,
    );
    return res.status(201).json({ items: created });
  } catch (error) {
    return res.status(500).json({ error: "Failed to sync columns." });
  }
});

app.get("/sync/columns", async (req, res) => {
  const parsed = parseOptionalDateParam(req.query.since);

  if (!parsed.ok) {
    return res.status(400).json({ error: parsed.error });
  }

  try {
    const items = await listColumnsSince(
      (req as AuthenticatedRequest).user.id,
      parsed.date,
    );
    return res.json({ items });
  } catch (error) {
    return res.status(500).json({ error: "Failed to sync columns." });
  }
});

app.post("/sync/cards", async (req, res) => {
  const items = Array.isArray(req.body?.items) ? req.body.items : null;

  if (!items) {
    return res.status(400).json({ error: "Invalid payload. Expecting items array." });
  }

  const inputs: CardInput[] = [];
  for (const entry of items) {
    const result = createCardFromPayload(entry);
    if (!result.ok) {
      return res.status(400).json({ error: result.error });
    }
    inputs.push(result.input);
  }

  try {
    const created = await createCardsBulk(
      (req as AuthenticatedRequest).user.id,
      inputs,
    );
    return res.status(201).json({ items: created });
  } catch (error) {
    return res.status(500).json({ error: "Failed to sync cards." });
  }
});

app.get("/sync/cards", async (req, res) => {
  const parsed = parseOptionalDateParam(req.query.since);

  if (!parsed.ok) {
    return res.status(400).json({ error: parsed.error });
  }

  try {
    const items = await listCardsSince(
      (req as AuthenticatedRequest).user.id,
      parsed.date,
    );
    return res.json({ items });
  } catch (error) {
    return res.status(500).json({ error: "Failed to sync cards." });
  }
});

app.use("/docs", swaggerUi.serve, swaggerUi.setup(openApiSpec));

