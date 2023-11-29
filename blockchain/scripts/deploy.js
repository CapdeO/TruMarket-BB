const { ethers, upgrades } = require("hardhat");

// --------->>>>>>>>>>>>>>>>>>>>>>     MUMBAI TESTNET
// USDT ADDRESS:           0xC1C86c89f795F161F82f77Ee6213D47460fEb4aE
// FACTORY PROXY ADDRESS:  0x5838c1543f1df470BE20a673F6CB384F500BdFbb
// FACTORY IMPL 1 ADDRESS: 0x723A0c575c517F8Ea8297967160F95b17BCdE5a3



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

// USDC
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
