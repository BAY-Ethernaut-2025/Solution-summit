import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  // get contract by address & abi
  const instanceAddress = "0xc1799808cF112D82Af0100cd537A4ed2740dE581";

  const abiPath = path.join(__dirname, "..", "abis", "fallback.json");
  if (!fs.existsSync(abiPath)) {
    console.error(`ABI file not found at ${abiPath}`);
    process.exit(1);
  }
  const abiJson = JSON.parse(fs.readFileSync(abiPath, "utf8"));

  const [signer] = await ethers.getSigners();

  const contract = new ethers.Contract(instanceAddress, abiJson, signer);
  console.log("Attached to contract:", contract.target);

  // function call
  // 1) contribute 0.0001 eth
  // const contributeTx = await contract.contribute({
  //   value: ethers.parseEther("0.0001"),
  // });
  // await contributeTx.wait();

  // 2) send 1 wei to contract
  // const tx = await signer.sendTransaction({
  //   to: instanceAddress,
  //   value: ethers.parseEther("0.000001"),
  // });
  // await tx.wait();

  // const owner = await contract.owner();
  // console.log("Current owner: ", owner);

  // 3) withdraw
  await contract.withdraw();
}

main().catch((err) => {
  console.error("Error:", err);
  process.exitCode = 1;
});
