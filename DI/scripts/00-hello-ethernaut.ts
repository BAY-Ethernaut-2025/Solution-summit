import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  // get contract by address & abi
  const instanceAddress = "0x537E1c15E62B0d8A792f2ae4Ccf8BDB8d7DD8f85";

  const abiPath = path.join(__dirname, "..", "abis", "hello_ethernaut.json");
  if (!fs.existsSync(abiPath)) {
    console.error(`ABI file not found at ${abiPath}`);
    process.exit(1);
  }
  const abiJson = JSON.parse(fs.readFileSync(abiPath, "utf8"));

  const [signer] = await ethers.getSigners();

  const contract = new ethers.Contract(instanceAddress, abiJson, signer);
  console.log("Attached to contract:", contract.target);

  // function call
  console.log(await contract.info());
  console.log(await contract.info1());
  console.log(await contract.info2("hello"));
  console.log(await contract.infoNum());
  console.log(await contract.info42());
  console.log(await contract.theMethodName());
  console.log(await contract.method7123949());
  console.log(await contract.password());
  console.log(await contract.authenticate("ethernaut0"));
}

main().catch((err) => {
  console.error("Error:", err);
  process.exitCode = 1;
});
