import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  // get contract by address & abi
  const instanceAddress = "0xe0bA1457F27516eA98B026f03dFbBd9F717e2B9d";

  const abiPath = path.join(__dirname, "..", "abis", "fallout.json");
  if (!fs.existsSync(abiPath)) {
    console.error(`ABI file not found at ${abiPath}`);
    process.exit(1);
  }
  const abiJson = JSON.parse(fs.readFileSync(abiPath, "utf8"));

  const [signer] = await ethers.getSigners();

  const contract = new ethers.Contract(instanceAddress, abiJson, signer);
  console.log("Attached to contract:", contract.target);

  // function call
  await contract.Fal1out();
}

main().catch((err) => {
  console.error("Error:", err);
  process.exitCode = 1;
});
