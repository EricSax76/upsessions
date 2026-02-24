import * as functions from 'firebase-functions';
import { defineSecret } from 'firebase-functions/params';

import { region } from './region';

type ArtistImagePayload = {
  imageUrl: string | null;
  spotifyUrl: string | null;
  source: 'spotify' | 'none';
};

type CachedArtistImage = {
  payload: ArtistImagePayload;
  expiresAtMs: number;
};

type SpotifyTokenCache = {
  token: string;
  expiresAtMs: number;
};

const ARTIST_CACHE_TTL_MS = 1000 * 60 * 60 * 12;
const MAX_ARTISTS_PER_REQUEST = 30;

const SPOTIFY_CLIENT_ID = defineSecret('SPOTIFY_CLIENT_ID');
const SPOTIFY_CLIENT_SECRET = defineSecret('SPOTIFY_CLIENT_SECRET');

let spotifyTokenCache: SpotifyTokenCache | null = null;
const artistImageCache = new Map<string, CachedArtistImage>();

function normalizeArtistName(name: string): string {
  return name.trim().toLowerCase();
}

function asString(value: unknown): string {
  return typeof value === 'string' ? value.trim() : '';
}

function parseArtistNames(value: unknown): string[] {
  if (!Array.isArray(value)) return [];

  const unique = new Set<string>();
  const parsed: string[] = [];

  for (const entry of value) {
    const name = asString(entry);
    if (!name) continue;

    const key = normalizeArtistName(name);
    if (unique.has(key)) continue;

    unique.add(key);
    parsed.push(name);

    if (parsed.length >= MAX_ARTISTS_PER_REQUEST) {
      break;
    }
  }

  return parsed;
}

async function fetchJson(
  url: string,
  init: {
    method?: string;
    headers?: Record<string, string>;
    body?: string;
  } = {},
): Promise<{ status: number; ok: boolean; body: unknown }> {
  const fetchFn = (globalThis as { fetch?: unknown }).fetch;
  if (typeof fetchFn !== 'function') {
    throw new Error('Fetch API no está disponible en este runtime');
  }

  const response = await (
    fetchFn as (
      input: string,
      options?: { method?: string; headers?: Record<string, string>; body?: string },
    ) => Promise<{
      status: number;
      ok: boolean;
      json: () => Promise<unknown>;
    }>
  )(url, init);

  let body: unknown = null;
  try {
    body = await response.json();
  } catch (_) {
    body = null;
  }

  return { status: response.status, ok: response.ok, body };
}

async function spotifyAccessToken(forceRefresh = false): Promise<string> {
  const now = Date.now();
  if (!forceRefresh && spotifyTokenCache != null && spotifyTokenCache.expiresAtMs > now) {
    return spotifyTokenCache.token;
  }

  const clientId = asString(SPOTIFY_CLIENT_ID.value());
  const clientSecret = asString(SPOTIFY_CLIENT_SECRET.value());
  if (!clientId || !clientSecret) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Faltan secretos de Spotify (SPOTIFY_CLIENT_ID / SPOTIFY_CLIENT_SECRET).',
    );
  }

  const credentials = Buffer.from(`${clientId}:${clientSecret}`).toString('base64');
  const tokenResponse = await fetchJson(
    'https://accounts.spotify.com/api/token',
    {
      method: 'POST',
      headers: {
        Authorization: `Basic ${credentials}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    },
  );

  if (!tokenResponse.ok || typeof tokenResponse.body !== 'object' || tokenResponse.body == null) {
    throw new functions.https.HttpsError(
      'internal',
      'No se pudo autenticar contra Spotify.',
    );
  }

  const payload = tokenResponse.body as Record<string, unknown>;
  const token = asString(payload.access_token);
  const expiresInSeconds = Number(payload.expires_in ?? 0);
  if (!token || !Number.isFinite(expiresInSeconds) || expiresInSeconds <= 0) {
    throw new functions.https.HttpsError(
      'internal',
      'Respuesta de token de Spotify inválida.',
    );
  }

  spotifyTokenCache = {
    token,
    expiresAtMs: now + expiresInSeconds * 1000 - 10_000,
  };
  return token;
}

function emptyArtistImage(): ArtistImagePayload {
  return {
    imageUrl: null,
    spotifyUrl: null,
    source: 'none',
  };
}

function parseSpotifyArtistImage(artistName: string, body: unknown): ArtistImagePayload {
  if (typeof body !== 'object' || body == null) {
    return emptyArtistImage();
  }

  const payload = body as Record<string, unknown>;
  const artists = payload.artists;
  if (typeof artists !== 'object' || artists == null) {
    return emptyArtistImage();
  }

  const artistsPayload = artists as Record<string, unknown>;
  const itemsRaw = artistsPayload.items;
  if (!Array.isArray(itemsRaw) || itemsRaw.length == 0) {
    return emptyArtistImage();
  }

  const normalizedTarget = normalizeArtistName(artistName);
  let selected: Record<string, unknown> | null = null;

  for (const item of itemsRaw) {
    if (typeof item !== 'object' || item == null) continue;
    const current = item as Record<string, unknown>;
    const currentName = normalizeArtistName(asString(current.name));
    if (currentName == normalizedTarget) {
      selected = current;
      break;
    }
  }

  selected = selected ?? (itemsRaw[0] as Record<string, unknown>);

  const imagesRaw = selected.images;
  const firstImage = Array.isArray(imagesRaw) && imagesRaw.length > 0
    ? (imagesRaw[0] as Record<string, unknown>)
    : null;

  const externalUrls = selected.external_urls;
  const external = typeof externalUrls === 'object' && externalUrls != null
    ? (externalUrls as Record<string, unknown>)
    : {};

  const imageUrl = firstImage == null ? '' : asString(firstImage['url']);
  const spotifyUrl = asString(external['spotify']);

  return {
    imageUrl: imageUrl.length === 0 ? null : imageUrl,
    spotifyUrl: spotifyUrl.length === 0 ? null : spotifyUrl,
    source: imageUrl.length === 0 ? 'none' : 'spotify',
  };
}

async function resolveArtistWithSpotify(
  artistName: string,
  token: string,
): Promise<ArtistImagePayload> {
  const encoded = encodeURIComponent(artistName);
  let searchResponse = await fetchJson(
    `https://api.spotify.com/v1/search?type=artist&limit=5&q=${encoded}`,
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  if (searchResponse.status == 401) {
    const refreshedToken = await spotifyAccessToken(true);
    searchResponse = await fetchJson(
      `https://api.spotify.com/v1/search?type=artist&limit=5&q=${encoded}`,
      {
        headers: {
          Authorization: `Bearer ${refreshedToken}`,
        },
      },
    );
  }

  if (!searchResponse.ok) {
    return emptyArtistImage();
  }

  return parseSpotifyArtistImage(artistName, searchResponse.body);
}

export const resolveSpotifyArtistImages = region
  .runWith({
    secrets: [SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET],
  })
  .https.onCall(async (data, context) => {
    if (!context.auth?.uid) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Debes iniciar sesión para resolver imágenes de artistas.',
      );
    }

    const payload = (data ?? {}) as Record<string, unknown>;
    const artistNames = parseArtistNames(payload.artistNames);
    if (artistNames.length === 0) {
      return { artists: {} };
    }

    const now = Date.now();
    const resolved: Record<string, ArtistImagePayload> = {};
    const pending: string[] = [];

    for (const artistName of artistNames) {
      const key = normalizeArtistName(artistName);
      const cached = artistImageCache.get(key);
      if (cached != null && cached.expiresAtMs > now) {
        resolved[artistName] = cached.payload;
        continue;
      }
      pending.push(artistName);
    }

    if (pending.length > 0) {
      const token = await spotifyAccessToken();
      const fetched = await Promise.all(
        pending.map(async (artistName) => {
          try {
            const payload = await resolveArtistWithSpotify(artistName, token);
            return [artistName, payload] as const;
          } catch (_) {
            return [artistName, emptyArtistImage()] as const;
          }
        }),
      );

      for (const [artistName, payload] of fetched) {
        const key = normalizeArtistName(artistName);
        artistImageCache.set(key, {
          payload,
          expiresAtMs: now + ARTIST_CACHE_TTL_MS,
        });
        resolved[artistName] = payload;
      }
    }

    return { artists: resolved };
  });
