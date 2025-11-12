import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  // get contract by address & abi
  const instanceAddress = "0xeA7f9A5b2E950456FD1e6b127504CB28929c16e4";

  const abiPath = path.join(__dirname, "..", "abis", "force.json");
  if (!fs.existsSync(abiPath)) {
    console.error(`ABI file not found at ${abiPath}`);
    process.exit(1);
  }
  const abiJson = JSON.parse(fs.readFileSync(abiPath, "utf8"));

  const [signer] = await ethers.getSigners();

  const contract = new ethers.Contract(instanceAddress, abiJson, signer);
  console.log("Attached to contract:", contract.target);

  // function call
  //   const attackContract = await ethers.getContractFactory("ForceAttack");
  //   const attack = await attackContract.deploy(instanceAddress, {
  //     value: ethers.parseEther("0.01"),
  //   });
  //   await attack.waitForDeployment();
  //   const attackAddress = await attack.getAddress();
  //   console.log("Attack Contract deployed:", attackAddress);
  console.log(
    "Force contract balance:",
    await ethers.provider.getBalance(instanceAddress)
  );
}

main().catch((err) => {
  console.error("Error:", err);
  process.exitCode = 1;
});
