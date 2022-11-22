import fs from "fs";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-preprocessor";
import { HardhatUserConfig, task } from "hardhat/config";
import * as dotenv from "dotenv";
dotenv.config();

const PRIVATE_KEY1 = process.env.PRIVATE_KEY1;
const PRIVATE_KEY2 = process.env.PRIVATE_KEY2;
const BSC_SCAN_API_KEY = process.env.BSC_SCAN_API_KEY;

if (!PRIVATE_KEY1 || !PRIVATE_KEY2 || !BSC_SCAN_API_KEY) {
  throw new Error("PRIVATE_KEY1, PRIVATE_KEY2 and BSC_SCAN_API_KEY must be set in .env file.");
}

import example from "./tasks/example";

function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean)
    .map((line) => line.trim().split("="));
}

task("example", "Example task").setAction(example);

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.13",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
    },
  },
  defaultNetwork: "bscTest",
  networks: {
    hardhat: {
      chainId: 1337,
      accounts: [
        {
          privateKey: `0x${PRIVATE_KEY1}`,
          balance: "10000000000000000000000"
        },
        {
          privateKey: `0x${PRIVATE_KEY2}`,
          balance: "10000000000000000000000"
        }
      ]
    },
    bscTest: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      accounts: [PRIVATE_KEY1, PRIVATE_KEY2]
    },
    bsc: {
      url: "https://bsc-dataseed1.binance.org",
      chainId: 56,
      accounts: [PRIVATE_KEY1, PRIVATE_KEY2]
    },
    localBscFork: {
      url: "http://127.0.0.1:8545/",
      chainId: 1337,
      accounts: [PRIVATE_KEY1, PRIVATE_KEY2]
    },
  },
  etherscan: {
    apiKey: BSC_SCAN_API_KEY
  },
  paths: {
    sources: "./src", // Use ./src rather than ./contracts as Hardhat expects
    cache: "./cache_hardhat", // Use a different cache for Hardhat than Foundry
  },
  // This fully resolves paths for imports in the ./lib directory for Hardhat
  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          getRemappings().forEach(([find, replace]) => {
            if (line.match(find)) {
              line = line.replace(find, replace);
            }
          });
        }
        return line;
      },
    }),
  },
};

export default config;
