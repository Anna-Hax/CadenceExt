export const IMPORT_REGEX = /(import\s+([A-Za-z_][A-Za-z0-9_]*)\s+from\s+0x)([A-Fa-f0-9]+)/g;

export function normalizeAddr(a?: string): string | undefined {
  if (!a) {return undefined;};
  let s = String(a).trim();
  if (s.startsWith("0x") || s.startsWith("0X")) {
    s = s.slice(2);
    }
  s = s.replace(/[^0-9a-fA-F]/g, "");
  if (s.length === 0) {
    return undefined;
  }
  return s.toLowerCase();
}
