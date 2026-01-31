import type { NextFunction, Request, Response } from "express";
import { createRemoteJWKSet, jwtVerify } from "jose";
import { ensureUser } from "./db";

export type AuthUser = {
  id: string;
};

export type AuthenticatedRequest = Request & { user: AuthUser };

const authDisabled = process.env.AUTH_DISABLED === "true";
const issuer = process.env.AUTH_ISSUER;
const audience = process.env.AUTH_AUDIENCE;
const jwksUrl = process.env.AUTH_JWKS_URL;

if (!authDisabled) {
  if (!issuer || !audience || !jwksUrl) {
    throw new Error(
      "AUTH_ISSUER, AUTH_AUDIENCE, and AUTH_JWKS_URL are required when auth is enabled.",
    );
  }
}

const jwks = !authDisabled && jwksUrl ? createRemoteJWKSet(new URL(jwksUrl)) : null;

function getBearerToken(req: Request): string | null {
  const header = req.header("authorization");
  if (!header) {
    return null;
  }

  const [scheme, token] = header.split(" ");
  if (scheme !== "Bearer" || !token) {
    return null;
  }

  return token;
}

export async function requireAuth(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    if (authDisabled) {
      const devUserId = process.env.AUTH_DEV_USER_ID ?? "dev-user";
      await ensureUser(devUserId);
      (req as AuthenticatedRequest).user = { id: devUserId };
      return next();
    }

    const token = getBearerToken(req);
    if (!token || !jwks || !issuer || !audience) {
      res.status(401).json({ error: "Unauthorized." });
      return;
    }

    const { payload } = await jwtVerify(token, jwks, {
      issuer,
      audience,
    });

    const userId = typeof payload.sub === "string" ? payload.sub : null;
    if (!userId) {
      res.status(401).json({ error: "Unauthorized." });
      return;
    }

    await ensureUser(userId);
    (req as AuthenticatedRequest).user = { id: userId };
    return next();
  } catch (error) {
    res.status(401).json({ error: "Unauthorized." });
  }
}
