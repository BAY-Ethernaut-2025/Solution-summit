import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  // get contract by address & abi
  const instanceAddress = "0x68baE5bA4b032F3Bec7771a90ec54444540C6E0b";

  const abiPath = path.join(__dirname, "..", "abis", "elevator.json");
  if (!fs.existsSync(abiPath)) {
    console.error(`ABI file not found at ${abiPath}`);
    process.exit(1);
  }
  const abiJson = JSON.parse(fs.readFileSync(abiPath, "utf8"));

  const [signer] = await ethers.getSigners();

  const contract = new ethers.Contract(instanceAddress, abiJson, signer);
  console.log("Attached to contract:", contract.target);

  // function call
  //   const attackContract = await ethers.getContractFactory("ElevatorAttack");
  //   const attack = await attackContract.deploy(instanceAddress);
  //   await attack.waitForDeployment();
  //   console.log("Attack Contract deployed:", await attack.getAddress());

  //   const tx = await attack.attack(63);
  //   await tx.wait();
  console.log(await contract.top());
  console.log(await contract.floor());
}

main().catch((err) => {
  console.error("Error:", err);
  process.exitCode = 1;
});
