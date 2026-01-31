import fs from "node:fs";
import path from "node:path";
import yaml from "js-yaml";

const OPENAPI_PATH = path.join(__dirname, "..", "openapi.yaml");

type OpenApiSpec = Record<string, unknown>;

export function loadOpenApiSpec(): OpenApiSpec {
  const raw = fs.readFileSync(OPENAPI_PATH, "utf8");
  return yaml.load(raw) as OpenApiSpec;
}

