import * as vscode from "vscode";
import * as fs from "fs/promises";
import * as path from "path";
import { FullMap } from "./types";
import { normalizeAddr } from "./utils";

/**
 * Read flow.json from workspaceFolder and build mapping network->(contract->address)
 */
export async function readFlowJsonAndBuildMapping(
  workspaceFolder: vscode.WorkspaceFolder,
  fileName = "flow.json"
): Promise<{ mapping: FullMap; networks: string[] } | null> {
  const full = path.join(workspaceFolder.uri.fsPath, fileName);
  let raw: string;
  try {
    raw = await fs.readFile(full, "utf8");
  } catch (e) {
    return null;
  }

  let parsed: any;
  try {
    parsed = JSON.parse(raw);
  } catch (e) {
    return null;
  }

  const mapping: FullMap = {};
  const networksSet = new Set<string>(Object.keys(parsed.networks || {}));

  const register = (contractName: string, aliases: any) => {
    if (!aliases || typeof aliases !== "object") return;
    Object.entries(aliases).forEach(([net, addrRaw]) => {
      networksSet.add(net);
      const addr = normalizeAddr(addrRaw as string);
      if (!addr) return;
      if (!mapping[net]) mapping[net] = {};
      mapping[net][contractName] = addr;
    });
  };

  if (parsed.contracts && typeof parsed.contracts === "object") {
    for (const [cname, cobj] of Object.entries(parsed.contracts)) {
      const aliases = (cobj as any).aliases || null;
      register(cname, aliases);

      const src = (cobj as any).source;
      if ((!aliases || Object.keys(aliases).length === 0) && typeof src === "string") {
        const m = src.match(/^([a-zA-Z0-9_-]+):\/\/([0-9a-fA-F]+)\.(.+)$/);
        if (m) {
          const net = m[1];
          const addr = normalizeAddr(m[2]);
          if (addr) {
            networksSet.add(net);
            if (!mapping[net]) mapping[net] = {};
            mapping[net][cname] = addr;
          }
        }
      }
    }
  }

  if (parsed.dependencies && typeof parsed.dependencies === "object") {
    for (const [dname, dobj] of Object.entries(parsed.dependencies)) {
      const aliases = (dobj as any).aliases || null;
      register(dname, aliases);

      const src = (dobj as any).source;
      if ((!aliases || Object.keys(aliases).length === 0) && typeof src === "string") {
        const m = src.match(/^([a-zA-Z0-9_-]+):\/\/([0-9a-fA-F]+)\.(.+)$/);
        if (m) {
          const net = m[1];
          const addr = normalizeAddr(m[2]);
          if (addr) {
            networksSet.add(net);
            if (!mapping[net]) mapping[net] = {};
            mapping[net][dname] = addr;
          }
        }
      }
    }
  }

  // ensure networks keys exist
  for (const net of Object.keys(parsed.networks || {})) {
    if (!mapping[net]) mapping[net] = {};
    networksSet.add(net);
  }

  return { mapping, networks: Array.from(networksSet) };
}
