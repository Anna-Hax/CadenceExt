import * as vscode from "vscode";
import { IMPORT_REGEX } from "./utils";
import { NetworkMap, ReplaceSummary } from "./types";

/**
 * Creates a WorkspaceEdit that replaces import addresses using netMap for the given workspaceFolder.
 */
export async function createEditForNetwork(
  workspaceFolder: vscode.WorkspaceFolder,
  netMap: NetworkMap,
  globs: string[]
): Promise<{ edit: vscode.WorkspaceEdit; summary: ReplaceSummary }> {
  const edit = new vscode.WorkspaceEdit();
  const fileList: { uri: string; replaced: number }[] = [];
  const missingSet = new Set<string>();
  let totalReplacements = 0;

  // find files for each glob
  const files: vscode.Uri[] = [];
  for (const g of globs) {
    const found = await vscode.workspace.findFiles(new vscode.RelativePattern(workspaceFolder, g), "**/node_modules/**");
    files.push(...found);
  }

  for (const uri of files) {
    const doc = await vscode.workspace.openTextDocument(uri);
    const text = doc.getText();
    let replacedInFile = 0;

    const newText = text.replace(IMPORT_REGEX, (fullMatch: string, prefix: string, name: string, oldAddr: string) => {
      const target = netMap[name];
      if (!target) {
        missingSet.add(name);
        return fullMatch;
      }
      replacedInFile += 1;
      totalReplacements += 1;
      return `${prefix}${target}`;
    });

    if (replacedInFile > 0 && newText !== text) {
      const fullRange = new vscode.Range(doc.positionAt(0), doc.positionAt(text.length));
      edit.replace(uri, fullRange, newText);
      fileList.push({ uri: uri.fsPath, replaced: replacedInFile });
    }
  }

  const summary: ReplaceSummary = {
    filesChanged: fileList.length,
    replacements: totalReplacements,
    missingContracts: Array.from(missingSet),
    fileList
  };

  return { edit, summary };
}
