import { app } from "./app";

const port = process.env.PORT ? Number(process.env.PORT) : 8000;

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`KanbanBoard API listening on port ${port}`);
});

