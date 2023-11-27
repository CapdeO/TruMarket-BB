var { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
var { expect } = require("chai");
var { ethers, upgrades } = require("hardhat");

describe("Testeando NFTFactory", () => {
    async function loadTest() {
        var [owner, alice, bob, carl] = await ethers.getSigners();

        var USDT = await ethers.getContractFactory("TetherUSD");
        var usdt = await USDT.deploy();
        var Factory = await ethers.getContractFactory("Factory");
        var factory = await upgrades.deployProxy(Factory, [

        ], { initializer: 'initialize', kind: 'uups' });

        return { factory, usdt, owner, alice, bob, carl };
    }

    describe("deploy", () => {
        it("deploy", async () => {
            var { factory, usdt, owner } = await loadFixture(loadTest);

            let name = 'Contrato dos toneladas de banana'
            let amountToFinance = 20000
            let fractions = 15

            let nft1Address = await factory.FactoryFunc(name, amountToFinance, fractions, usdt.target)

            let nft1Instance = new ethers.Contract(nft1Address, FinancingContract.interface, owner);

            let namee = await nft1Instance.name();
            console.log(namee);

        });

    });

});