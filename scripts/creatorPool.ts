import { ethers } from "ethers";
import { parseUnits } from "ethers/lib/utils.js";

const RPC_URL = "https://sepolia.infura.io/v3/YOUR_INFURA_KEY"; // or Alchemy
const CONTRACT_ADDRESS = "0x8B5e027068b9d819934c82cC48AE281706428fE0";

export const customPoolABI = [
  {
    inputs: [
      {
        internalType: "address",
        name: "initialOwner",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "owner",
        type: "address",
      },
    ],
    name: "OwnableInvalidOwner",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
    ],
    name: "OwnableUnauthorizedAccount",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "uint256",
        name: "creatorId",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "newBalance",
        type: "uint256",
      },
    ],
    name: "CreatorBalanceUpdated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "uint256",
        name: "creatorId",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "receiver",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "RewardDistributed",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    name: "creatorBalances",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    name: "creatorTokens",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "creatorId",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "receiver",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
    ],
    name: "distributeReward",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "creatorId",
        type: "uint256",
      },
    ],
    name: "getCreatorPoolBalance",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "operator",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_operator",
        type: "address",
      },
    ],
    name: "setOperator",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "creatorId",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "token",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "newBalance",
        type: "uint256",
      },
    ],
    name: "updateCreatorBalance",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

// ------------------ SCRIPT ------------------
async function main() {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://base-sepolia.drpc.org"
  );

  console.log(provider);

  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

  const CreatorPool = new ethers.Contract(
    CONTRACT_ADDRESS,
    customPoolABI,
    wallet
  );

  // Example creators
  const creators = [
    { id: 1, coinAddress: "0xf3922e301c8ea21a52ecd9e6c0f708557611e8e6" },
    { id: 4, coinAddress: "0x29aef64de9460338a9947b6561825eefe7d5fa4a" },
    { id: 5, coinAddress: "0xea71a08bb70a19538473c43a6c4fa7912ad077fe" },
    { id: 7, coinAddress: "0xb39ed36589a3508ad8a78e170551a26c7dfecb2e" },
  ];

  const balance = parseUnits("1000000000", 0); // plain integer

  for (const creator of creators) {
    console.log(`Updating balance for creator ${creator.id}...`);
    const tx = await CreatorPool.updateCreatorBalance(
      creator.id,
      creator.coinAddress,
      balance
    );
    console.log(`⏳ Tx sent: ${tx.hash}`);
    await tx.wait();
    console.log(
      `✅ Creator ${creator.id} balance updated to ${balance.toString()}`
    );
  }
}

// Run
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
