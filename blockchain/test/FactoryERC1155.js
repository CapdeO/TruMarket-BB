var { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
var { expect } = require("chai");
var { ethers, upgrades } = require("hardhat");

async function getContract(_add) {
    return await ethers.getContractAt("FinancingContract1155", _add);
}

describe("Testing FactoryERC1155", () => {
    async function loadTest() {
        var [owner, alice, bob, carl] = await ethers.getSigners();

        var USDT = await ethers.getContractFactory("TetherUSD");
        var usdt = await USDT.deploy();
        var Factory = await ethers.getContractFactory("Factory");
        var factory = await upgrades.deployProxy(Factory, [
        ], { initializer: 'initialize', kind: 'uups' });

        return { factory, usdt, owner, alice, bob, carl };
    }

    describe("Create contract", () => {
        it("Factory", async () => {
            var { factory, usdt } = await loadFixture(loadTest);

            let name = 'Contrato dos toneladas de banana'
            let operationAmount = 25000
            let amountToFinance = 20000
            let fractions = 15

            let tx = await factory.FactoryFunc(name, operationAmount, amountToFinance, fractions, usdt.target);
            let array = await factory.getAddresses()
            let address = array[0]
            let newERC721Contract = await getContract(address)

            await expect(tx).to.emit(factory, "ContractCreated").withArgs(address);
            expect(await newERC721Contract.name()).to.be.equal(name)
            expect(await newERC721Contract.symbol()).to.be.equal('TM1')
            expect(await newERC721Contract.operationAmount()).to.be.equal(operationAmount)
            expect(await newERC721Contract.amountToFinance()).to.be.equal(amountToFinance)
            expect(await newERC721Contract.investmentFractions()).to.be.equal(fractions)
            expect(await factory.contractsCounter()).to.be.equal(1)

            let name2 = 'Mango Heaven 50 TON'
            let operationAmount2 = 12000
            let amountToFinance2 = 10000
            let fractions2 = 105

            let tx2 = await factory.FactoryFunc(name2, operationAmount2, amountToFinance2, fractions2, usdt.target);
            array = await factory.getAddresses()
            let address2 = array[1]
            let newERC721Contract2 = await getContract(address2)

            await expect(tx2).to.emit(factory, "ContractCreated").withArgs(address2);
            expect(await newERC721Contract2.name()).to.be.equal(name2)
            expect(await newERC721Contract2.symbol()).to.be.equal('TM2')
            expect(await newERC721Contract2.amountToFinance()).to.be.equal(amountToFinance2)
            expect(await newERC721Contract2.investmentFractions()).to.be.equal(fractions2)
            expect(await factory.contractsCounter()).to.be.equal(2)
        });

        // it("Invest", async () => {
        //     var { factory, usdt, alice } = await loadFixture(loadTest);

        //     let name = 'Contract'
        //     let amountToFinance = 20000
        //     let fractions = 200
        //     let price = (amountToFinance / fractions) * (10 ** 6)
        //     await factory.FactoryFunc(name, amountToFinance, fractions, usdt.target);
        //     let array = await factory.getAddresses()
        //     let address = array[0]
        //     let newERC721Contract = await getContract(address)
        //     let NFTsAmount = 5
        //     let NFTsPriceInWei = NFTsAmount * price

        //     await usdt.mint(alice, NFTsPriceInWei)
        //     await usdt.connect(alice).approve(newERC721Contract.target, NFTsPriceInWei)

        //     await newERC721Contract.connect(alice).buyFraction(NFTsAmount)

        //     expect(await newERC721Contract.balanceOf(alice.address)).to.be.equal(NFTsAmount)
        //     expect(await usdt.balanceOf(newERC721Contract.target)).to.be.equal(NFTsPriceInWei)
        //     expect(await usdt.balanceOf(alice.address)).to.be.equal(0)
        // });
    });
});

describe("Testing FinancingContract", async () => {
    async function loadTest() {
        var [owner, alice, bob, carl, peter] = await ethers.getSigners();

        var USDT = await ethers.getContractFactory("TetherUSD");
        var usdt = await USDT.deploy();
        var addressUSDT = usdt.target
        
        var name = "ExampleApple"
        var symbol = "BTC"
        var operationAmount = 12000
        var amountToFinance = 10000
        var investmentFractions = 10
        
        var FinancingContract = await ethers.getContractFactory("FinancingContract1155");
        var financing = await FinancingContract.deploy(
            name, symbol, operationAmount, amountToFinance, investmentFractions, addressUSDT
        );

        return { usdt, financing, owner, alice, bob, carl, peter }
    }

    describe("Testing buyFraction", async () => {
        it("Price in Wei", async () => {
            var { usdt, financing, owner, alice, bob, carl } = await loadFixture(loadTest)


            //expect price * (10**6)
        })
    })


}) 