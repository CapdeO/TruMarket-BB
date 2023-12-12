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

    describe("Deploy", () => {
        it("Parameters", async () => {
            var { factory, usdt } = await loadFixture(loadTest);

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
        });

        it("Invest", async () => {
            var { factory, usdt, alice } = await loadFixture(loadTest);

            let name = 'Contract'
            let amountToFinance = 20000
            let fractions = 200
            let price = (amountToFinance / fractions) * (10 ** 6)
            await factory.FactoryFunc(name, amountToFinance, fractions, usdt.target);
            let array = await factory.getAddresses()
            let address = array[0]
            let newERC721Contract = await getContract(address)
            let NFTsAmount = 5
            let NFTsPriceInWei = NFTsAmount * price

            await usdt.mint(alice, NFTsPriceInWei)
            await usdt.connect(alice).approve(newERC721Contract.target, NFTsPriceInWei)

            await newERC721Contract.connect(alice).buyFraction(NFTsAmount)

            expect(await newERC721Contract.balanceOf(alice.address)).to.be.equal(NFTsAmount)
            expect(await usdt.balanceOf(newERC721Contract.target)).to.be.equal(NFTsPriceInWei)
            expect(await usdt.balanceOf(alice.address)).to.be.equal(0)
        });
    });
});

describe("Testing FinancingContract", async () => {
    async function loadTest() {
        var [owner, alice, bob, carl] = await ethers.getSigners();

        var name = "ExampleApple"
        var symbol = "APP"
        var amountToFinance = 10000
        var investmentFractions = 10
        var usdt = usdt

        var USDT = await ethers.getContractFactory("TetherUSD");
        var usdt = await USDT.deploy();
        var FinancingContract = await ethers.getContractFactory("FinancingContract1155");
        var financing = await FinancingContract.deploy(name, symbol, amountToFinance, investmentFractions, usdt.address);
    
        return {usdt, financing, owner, alice, bob, carl}
    }
    describe("Testing buyFraction", async () => {
        it("Price in Wei", async () => {
            var {usdt, financing, owner, alice, bob, carl} = await loadFixture(loadTest)

            var amount = 1000

            //expect price * (10**6)
        })
    })
}) 