import * as vscode from "vscode";
import { readFlowJsonAndBuildMapping } from "./flowReader";
import { createEditForNetwork } from "./replacer";
import { normalizeAddr } from "./utils";

const STATUS_KEY = "flowContracts.currentNetwork";

export async function activate(context: vscode.ExtensionContext) {
  const statusBar = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
  context.subscriptions.push(statusBar);

  async function updateStatusBarLabel(folder?: vscode.WorkspaceFolder) {
    const current = context.globalState.get<string>(STATUS_KEY);
    if (current) {
      statusBar.text = `Flow: ${current}`;
      statusBar.tooltip = `Current Flow network: ${current} (click to switch)`;
      statusBar.command = "flowContracts.switchNetwork";
      statusBar.show();
    } else {
      statusBar.text = `Flow: (not set)`;
      statusBar.command = "flowContracts.switchNetwork";
      statusBar.show();
    }
  }

  // on startup set label
  await updateStatusBarLabel();

  // command: select workspace and switch (useful in multi-root)
  context.subscriptions.push(
    vscode.commands.registerCommand("flowContracts.selectWorkspaceAndSwitch", async () => {
      const folders = vscode.workspace.workspaceFolders;
      if (!folders || folders.length === 0) {
        vscode.window.showErrorMessage("Open a workspace folder containing flow.json first.");
        return;
      }
      const picked = await vscode.window.showQuickPick(folders.map(f => f.name), { placeHolder: "Select workspace folder" });
      if (!picked) return;
      const folder = folders.find(f => f.name === picked)!;
      await runSwitchForFolder(folder);
    })
  );

  // main command
  context.subscriptions.push(
    vscode.commands.registerCommand("flowContracts.switchNetwork", async () => {
      const folders = vscode.workspace.workspaceFolders;
      if (!folders || folders.length === 0) {
        vscode.window.showErrorMessage("Open a workspace folder containing flow.json first.");
        return;
      }

      let workspaceFolder: vscode.WorkspaceFolder | undefined;
      if (folders.length === 1) {
        workspaceFolder = folders[0];
      } else {
        // if last workspace used stored, prefer it
        const lastWorkspace = context.globalState.get<string>("flowContracts.lastWorkspace");
        if (lastWorkspace) {
          workspaceFolder = folders.find(f => f.uri.fsPath === lastWorkspace) || folders[0];
        } else {
          const pick = await vscode.window.showQuickPick(folders.map(f => f.name), { placeHolder: "Select workspace folder" });
          if (!pick) return;
          workspaceFolder = folders.find(f => f.name === pick);
        }
      }

      if (!workspaceFolder) {
        vscode.window.showErrorMessage("No workspace selected.");
        return;
      }

      // persist last used workspace
      await context.globalState.update("flowContracts.lastWorkspace", workspaceFolder.uri.fsPath);

      await runSwitchForFolder(workspaceFolder);
    })
  );

  async function runSwitchForFolder(workspaceFolder: vscode.WorkspaceFolder) {
    const cfgName = vscode.workspace.getConfiguration().get<string>("flowContracts.flowFileName", "flow.json");
    const flowRes = await readFlowJsonAndBuildMapping(workspaceFolder, cfgName);
    if (!flowRes) {
      const create = "Create flow.json";
      const r = await vscode.window.showErrorMessage(`Could not read ${cfgName} in ${workspaceFolder.name}.`, create);
      if (r === create) {
        const full = vscode.Uri.joinPath(workspaceFolder.uri, cfgName);
        const sample = {
          contracts: {},
          networks: {},
          dependencies: {}
        };
        await vscode.workspace.fs.writeFile(full, Buffer.from(JSON.stringify(sample, null, 2), "utf8"));
        vscode.window.showInformationMessage(`${cfgName} created in ${workspaceFolder.name}. Please edit and run again.`);
      }
      return;
    }

    const { mapping, networks } = flowRes;
    if (networks.length === 0) {
      vscode.window.showErrorMessage("No networks found in flow.json.");
      return;
    }

    // prefer persisted network first
    const lastNet = context.globalState.get<string>(STATUS_KEY);
    let picked: string | undefined;
    if (lastNet && networks.includes(lastNet)) {
      const quick = `${lastNet} (last used)`;
      const q = await vscode.window.showQuickPick([quick, ...networks.filter(n => n !== lastNet)], {
        placeHolder: "Pick Flow network to apply contract addresses",
        ignoreFocusOut: true
      });
      if (!q) return;
      picked = q === quick ? lastNet : q;
    } else {
      picked = await vscode.window.showQuickPick(networks, { placeHolder: "Pick Flow network", ignoreFocusOut: true });
      if (!picked) return;
    }

    // persist choice (status + global)
    await context.globalState.update(STATUS_KEY, picked);
    statusBar.text = `Flow: ${picked}`;
    statusBar.show();

    // confirm/preview
    const confirm = await vscode.window.showQuickPick(["Apply now", "Preview changes", "Cancel"], {
      placeHolder: `Apply addresses for ${picked}?`
    });
    if (!confirm || confirm === "Cancel") return;

    const globs = vscode.workspace.getConfiguration().get<string[]>("flowContracts.findGlobs", ["**/*.cdc", "**/*.cadence"]);
    const netMap = mapping[picked] || {};

    const { edit, summary } = await createEditForNetwork(workspaceFolder, netMap, globs);

    if (summary.filesChanged === 0) {
      vscode.window.showInformationMessage(`No imports updated for network "${picked}". Missing mappings: ${summary.missingContracts.length}`);
      return;
    }

    if (confirm === "Preview changes") {
      // Apply and open modified files then ask to keep or revert
      const applied = await vscode.workspace.applyEdit(edit);
      if (!applied) {
        vscode.window.showErrorMessage("Failed to apply preview edits.");
        return;
      }
      // open changed files
      for (const f of summary.fileList) {
        const doc = await vscode.workspace.openTextDocument(f.uri);
        await vscode.window.showTextDocument(doc, { preview: false });
      }
      const keep = "Keep changes";
      const revert = "Revert";
      const choice = await vscode.window.showInformationMessage(`Preview applied: ${summary.filesChanged} files changed. Keep?`, keep, revert);
      if (choice === revert || !choice) {
        // revert all opened files (simple approach)
        await vscode.commands.executeCommand("workbench.action.files.revert");
        vscode.window.showInformationMessage("Changes reverted.");
        return;
      } else {
        // save all dirty docs
        await Promise.all(vscode.workspace.textDocuments.filter(d => d.isDirty).map(d => d.save()));
        vscode.window.showInformationMessage(`Applied ${summary.replacements} replacements in ${summary.filesChanged} files for "${picked}".`);
      }
    } else {
      const ok = await vscode.workspace.applyEdit(edit);
      if (!ok) {
        vscode.window.showErrorMessage("Failed to apply edits.");
        return;
      }
      await Promise.all(vscode.workspace.textDocuments.filter(d => d.isDirty).map(d => d.save()));
      vscode.window.showInformationMessage(`Updated ${summary.filesChanged} files with ${summary.replacements} replacements for "${picked}".`);
    }
  }

  // click status bar to switch
  context.subscriptions.push(statusBar);
}

export function deactivate() {}
