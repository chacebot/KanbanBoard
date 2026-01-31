import { Pool } from "pg";

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error("DATABASE_URL is required to start the backend.");
}

const pool = new Pool({ connectionString });

type BoardRow = {
  id: string;
  title: string;
  created_at: Date;
};

type ColumnRow = {
  id: string;
  board_id: string;
  title: string;
  position: number;
  created_at: Date;
};

type CardRow = {
  id: string;
  column_id: string;
  title: string;
  description: string | null;
  position: number;
  created_at: Date;
};

export type BoardInput = {
  title: string;
};

export type ColumnInput = {
  boardId: string;
  title: string;
  position: number;
};

export type CardInput = {
  columnId: string;
  title: string;
  description: string | null;
  position: number;
};

export type BoardRecord = {
  id: string;
  title: string;
  createdAt: string;
};

export type ColumnRecord = {
  id: string;
  boardId: string;
  title: string;
  position: number;
  createdAt: string;
};

export type CardRecord = {
  id: string;
  columnId: string;
  title: string;
  description: string | null;
  position: number;
  createdAt: string;
};

function mapBoard(row: BoardRow): BoardRecord {
  return {
    id: row.id,
    title: row.title,
    createdAt: row.created_at.toISOString(),
  };
}

function mapColumn(row: ColumnRow): ColumnRecord {
  return {
    id: row.id,
    boardId: row.board_id,
    title: row.title,
    position: row.position,
    createdAt: row.created_at.toISOString(),
  };
}

function mapCard(row: CardRow): CardRecord {
  return {
    id: row.id,
    columnId: row.column_id,
    title: row.title,
    description: row.description,
    position: row.position,
    createdAt: row.created_at.toISOString(),
  };
}

export async function ensureUser(id: string): Promise<void> {
  await pool.query(
    "INSERT INTO users (id) VALUES ($1) ON CONFLICT (id) DO NOTHING",
    [id],
  );
}

export async function listBoards(userId: string): Promise<BoardRecord[]> {
  const result = await pool.query<BoardRow>(
    `SELECT id, title, created_at
     FROM boards
     WHERE user_id = $1
     ORDER BY created_at DESC`,
    [userId],
  );
  return result.rows.map(mapBoard);
}

export async function listBoardsSince(
  userId: string,
  since: Date | null,
): Promise<BoardRecord[]> {
  if (!since) {
    return listBoards(userId);
  }

  const result = await pool.query<BoardRow>(
    `SELECT id, title, created_at
     FROM boards
     WHERE user_id = $1 AND created_at > $2
     ORDER BY created_at DESC`,
    [userId, since],
  );
  return result.rows.map(mapBoard);
}

export async function getBoardById(
  userId: string,
  boardId: string,
): Promise<BoardRecord | null> {
  const result = await pool.query<BoardRow>(
    `SELECT id, title, created_at
     FROM boards
     WHERE user_id = $1 AND id = $2`,
    [userId, boardId],
  );

  if (result.rowCount === 0) {
    return null;
  }

  return mapBoard(result.rows[0]);
}

export async function createBoard(
  userId: string,
  input: BoardInput,
): Promise<BoardRecord> {
  const result = await pool.query<BoardRow>(
    `INSERT INTO boards (id, user_id, title)
     VALUES (gen_random_uuid(), $1, $2)
     RETURNING id, title, created_at`,
    [userId, input.title],
  );
  return mapBoard(result.rows[0]);
}

export async function createBoardsBulk(
  userId: string,
  items: BoardInput[],
): Promise<BoardRecord[]> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const created: BoardRecord[] = [];
    for (const input of items) {
      const result = await client.query<BoardRow>(
        `INSERT INTO boards (id, user_id, title)
         VALUES (gen_random_uuid(), $1, $2)
         RETURNING id, title, created_at`,
        [userId, input.title],
      );
      created.push(mapBoard(result.rows[0]));
    }
    await client.query("COMMIT");
    return created;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

export async function listColumns(
  userId: string,
  boardId: string,
): Promise<ColumnRecord[]> {
  const result = await pool.query<ColumnRow>(
    `SELECT id, board_id, title, position, created_at
     FROM columns
     WHERE user_id = $1 AND board_id = $2
     ORDER BY position ASC`,
    [userId, boardId],
  );
  return result.rows.map(mapColumn);
}

export async function listColumnsSince(
  userId: string,
  since: Date | null,
): Promise<ColumnRecord[]> {
  if (!since) {
    const result = await pool.query<ColumnRow>(
      `SELECT id, board_id, title, position, created_at
       FROM columns
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [userId],
    );
    return result.rows.map(mapColumn);
  }

  const result = await pool.query<ColumnRow>(
    `SELECT id, board_id, title, position, created_at
     FROM columns
     WHERE user_id = $1 AND created_at > $2
     ORDER BY created_at DESC`,
    [userId, since],
  );
  return result.rows.map(mapColumn);
}

export async function getColumnById(
  userId: string,
  columnId: string,
): Promise<ColumnRecord | null> {
  const result = await pool.query<ColumnRow>(
    `SELECT id, board_id, title, position, created_at
     FROM columns
     WHERE user_id = $1 AND id = $2`,
    [userId, columnId],
  );

  if (result.rowCount === 0) {
    return null;
  }

  return mapColumn(result.rows[0]);
}

export async function createColumn(
  userId: string,
  input: ColumnInput,
): Promise<ColumnRecord> {
  const result = await pool.query<ColumnRow>(
    `INSERT INTO columns (id, user_id, board_id, title, position)
     VALUES (gen_random_uuid(), $1, $2, $3, $4)
     RETURNING id, board_id, title, position, created_at`,
    [userId, input.boardId, input.title, input.position],
  );
  return mapColumn(result.rows[0]);
}

export async function createColumnsBulk(
  userId: string,
  items: ColumnInput[],
): Promise<ColumnRecord[]> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const created: ColumnRecord[] = [];
    for (const input of items) {
      const result = await client.query<ColumnRow>(
        `INSERT INTO columns (id, user_id, board_id, title, position)
         VALUES (gen_random_uuid(), $1, $2, $3, $4)
         RETURNING id, board_id, title, position, created_at`,
        [userId, input.boardId, input.title, input.position],
      );
      created.push(mapColumn(result.rows[0]));
    }
    await client.query("COMMIT");
    return created;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

export async function listCards(
  userId: string,
  columnId: string,
): Promise<CardRecord[]> {
  const result = await pool.query<CardRow>(
    `SELECT id, column_id, title, description, position, created_at
     FROM cards
     WHERE user_id = $1 AND column_id = $2
     ORDER BY position ASC`,
    [userId, columnId],
  );
  return result.rows.map(mapCard);
}

export async function listCardsSince(
  userId: string,
  since: Date | null,
): Promise<CardRecord[]> {
  if (!since) {
    const result = await pool.query<CardRow>(
      `SELECT id, column_id, title, description, position, created_at
       FROM cards
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [userId],
    );
    return result.rows.map(mapCard);
  }

  const result = await pool.query<CardRow>(
    `SELECT id, column_id, title, description, position, created_at
     FROM cards
     WHERE user_id = $1 AND created_at > $2
     ORDER BY created_at DESC`,
    [userId, since],
  );
  return result.rows.map(mapCard);
}

export async function getCardById(
  userId: string,
  cardId: string,
): Promise<CardRecord | null> {
  const result = await pool.query<CardRow>(
    `SELECT id, column_id, title, description, position, created_at
     FROM cards
     WHERE user_id = $1 AND id = $2`,
    [userId, cardId],
  );

  if (result.rowCount === 0) {
    return null;
  }

  return mapCard(result.rows[0]);
}

export async function createCard(
  userId: string,
  input: CardInput,
): Promise<CardRecord> {
  const result = await pool.query<CardRow>(
    `INSERT INTO cards (id, user_id, column_id, title, description, position)
     VALUES (gen_random_uuid(), $1, $2, $3, $4, $5)
     RETURNING id, column_id, title, description, position, created_at`,
    [userId, input.columnId, input.title, input.description, input.position],
  );
  return mapCard(result.rows[0]);
}

export async function createCardsBulk(
  userId: string,
  items: CardInput[],
): Promise<CardRecord[]> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const created: CardRecord[] = [];
    for (const input of items) {
      const result = await client.query<CardRow>(
        `INSERT INTO cards (id, user_id, column_id, title, description, position)
         VALUES (gen_random_uuid(), $1, $2, $3, $4, $5)
         RETURNING id, column_id, title, description, position, created_at`,
        [userId, input.columnId, input.title, input.description, input.position],
      );
      created.push(mapCard(result.rows[0]));
    }
    await client.query("COMMIT");
    return created;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

export async function closePool(): Promise<void> {
  await pool.end();
}
