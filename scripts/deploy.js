const { ethers, upgrades } = require("hardhat");

// --------->>>>>>>>>>>>>>>>>>>>>>     MUMBAI TESTNET
// USDT ADDRESS:              0x7a6C7a3bab11D57423f9F5690AF6ff38BE2d771f
// FACTORY PROXY ADDRESS:     0xA8835aFe5868e10677050b56B1dEe0C56ac4cA4d
// FACTORY IMPL 1 ADDRESS:    0xC218767C0ff2357D609f67D5cC4Efa427Db04126

// Factory upgradeable
async function factory() {
  var UpgradeableFactory = await hre.ethers.getContractFactory("Factory");

  var upgradeableFactory = await upgrades.deployProxy(UpgradeableFactory, [], {
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

// USDT
async function usdt() {
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
factory().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
