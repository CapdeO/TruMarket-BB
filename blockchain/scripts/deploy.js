const hre = require("hardhat");

// Factory upgradeable
async function main() {
  var UpgradeableFactory = await hre.ethers.getContractFactory("Factory");

  var upgradeableFactory = await UpgradeableFactory.deployProxy(UpgradeableFactory, [], {
    kind: "uups",
  });

  var tx = await upgradeableFactory.waitForDeployment();
  await tx.deploymentTransaction().wait(5);

  var impFactoryAdd = await upgrades.erc1967.getImplementationAddress(
    await upgradeableFactory.getAddress()
  );

  console.log(`Address del Proxy es: ${await upgradeableFactory.getAddress()}`);
  console.log(`Address de Impl es: ${impFactoryAdd}`);

  await hre.run("verify:verify", {
    address: impFactoryAdd,
    constructorArguments: [],
  });
}

// USDC
async function main() {
  var contractUSDC = await ethers.deployContract("TetherUSD");
  console.log(`Address del contrato ${await contractUSDC.getAddress()}`)

  var res = await contractUSDC.waitForDeployment();
  await res.deploymentTransaction().wait(5);

  await hre.run("verify:verify", {
    address: await contractUSDC.getAddress(),
    constructorArguments: [],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
