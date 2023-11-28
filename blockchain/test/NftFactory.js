var { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
var { expect } = require("chai");
var { ethers, upgrades } = require("hardhat");

async function getContract(_add) {
    return await ethers.getContractAt("FinancingContract", _add);
}

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

            let tx = await factory.FactoryFunc(name, amountToFinance, fractions, usdt.target);
            let receipt = await tx.wait()
            let array = await factory.getAddresses()
            let address = array[0]
            let newERC721Contract = await getContract(address)

            expect(await newERC721Contract.name()).to.be.equal(name)
            expect(await newERC721Contract.symbol()).to.be.equal('TM1')
            expect(await newERC721Contract.amountToFinance()).to.be.equal(amountToFinance)
            expect(await newERC721Contract.investmentFractions()).to.be.equal(fractions)
            expect(await factory.contractsCounter()).to.be.equal(1)

            // console.log(await newERC721Contract.contractStatus())
        });
    });



});