export type NetworkMap = { [contract: string]: string };
export type FullMap = { [network: string]: NetworkMap };

export type ReplaceSummary = {
  filesChanged: number;
  replacements: number;
  missingContracts: string[]; // contracts referenced but missing in mapping
  fileList: { uri: string; replaced: number }[];
};
