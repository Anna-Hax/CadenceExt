# CadenceHelper — Flow/Cadence Import Address Switcher

CadenceHelper is a VS Code extension that automatically updates all Cadence `import` addresses (`import ContractName from 0x...`) across your project using the address aliases defined in your project's `flow.json`.

This makes switching between emulator, testnet, mainnet, or any other configured network fast and error-free.

---

## Features

### 1. One-click Network Switching
Select a network (emulator, testnet, mainnet, etc.) and CadenceHelper updates all relevant import statements across your workspace.

Example:

```cadence
import ContractX from 0xf8d6e05860000000
````

After switching to testnet:

```cadence
import HeroManager from 0xc6e616f1e5000000
```

---

### 2. Automatically Reads `flow.json`

CadenceHelper parses your project's `flow.json` and extracts:

* `contracts[*].aliases`
* `dependencies[*].aliases`
* fallback formats like `network://address.ContractName`

Example:

```json
"contracts": {
  "ContractX": {
    "aliases": {
      "emulator": "f8d6e05860000000",
      "testnet": "c6e616f1e5000000"
    }
  }
}
```

---

### 3. Bulk Update of Cadence Files

All Cadence files in your project are updated automatically.
By default, CadenceHelper scans:

```
**/*.cdc
**/*.cadence
```

---

### 4. Preview Before Applying

Before import updates are finalized, you can choose:

* Apply now
* Preview changes
* Cancel

Preview mode shows all modified files and lets you decide whether to keep or revert the changes.

---

### 5. Smart Handling of Missing Aliases

If a contract import does not have an alias for the chosen network:

* The original import is left unchanged.
* A report is shown listing all contracts missing address mappings.

---

### 6. Status Bar Network Indicator

The VS Code status bar displays the currently selected network.
Clicking it reopens the network switch dialog.

---

### 7. Remembers Last Selected Network

CadenceHelper stores the last active network and uses it automatically when switching again.

---

### 8. Multi-Root Workspace Support

When multiple workspace folders are open, CadenceHelper prompts the user to select which folder to apply updates to.

---

## Requirements

* A Flow project containing a `flow.json` file in the workspace root.
* Cadence files that use import syntax of the form:

```cadence
import ContractName from 0x1234567890abcdef
```

---

## Extension Settings

CadenceHelper contributes the following settings:

### `flowContracts.findGlobs`

Glob patterns used to discover Cadence files.

Default:

```json
["**/*.cdc", "**/*.cadence"]
```

### `flowContracts.flowFileName`

Path or name of the Flow configuration file.

Default:

```json
"flow.json"
```

---

## Known Issues

* Multi-import syntax such as
  `import A, B from 0x...`
  is not currently supported.
* Unusual or non-standard address formats in `flow.json` may not parse correctly.

---

## Release Notes

### 1.0.0

Initial release with:

* Network switching
* `flow.json` parsing (contracts and dependencies)
* Bulk import updating
* Preview mode
* Status bar network indicator
* Last used network persistence
* Multi-root workspace support

---

## Working With Markdown

Useful VS Code shortcuts:

* Split editor: `Ctrl+\`
* Toggle preview: `Ctrl+Shift+V`
* Markdown autocomplete: `Ctrl+Space`

---

## More Information

* Flow documentation: [https://developers.flow.com](https://developers.flow.com)
* Cadence reference: [https://developers.flow.com/cadence](https://developers.flow.com/cadence)
* VS Code Extension API: [https://code.visualstudio.com/api](https://code.visualstudio.com/api)

```

