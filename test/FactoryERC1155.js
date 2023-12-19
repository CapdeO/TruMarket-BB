var { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
var { expect } = require("chai");
var { ethers, network, upgrades } = require("hardhat");
var { time } = require("@nomicfoundation/hardhat-network-helpers");
ID = 0;

async function getContract(_add) {
    return await ethers.getContractAt("FinancingContract1155", _add);
}

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
            let newERC1155Contract = await getContract(address)

            await expect(tx).to.emit(factory, "ContractCreated").withArgs(address);
            expect(await newERC1155Contract.name()).to.be.equal(name)
            expect(await newERC1155Contract.symbol()).to.be.equal('TM1')
            expect(await newERC1155Contract.operationAmount()).to.be.equal(operationAmount)
            expect(await newERC1155Contract.amountToFinance()).to.be.equal(amountToFinance)
            expect(await newERC1155Contract.investmentFractions()).to.be.equal(fractions)
            expect(await factory.contractsCounter()).to.be.equal(1)

            let name2 = 'Mango Heaven 50 TON'
            let operationAmount2 = 12000
            let amountToFinance2 = 10000
            let fractions2 = 105

            let tx2 = await factory.FactoryFunc(name2, operationAmount2, amountToFinance2, fractions2, usdt.target);
            array = await factory.getAddresses()
            let address2 = array[1]
            let newERC1155Contract2 = await getContract(address2)

            await expect(tx2).to.emit(factory, "ContractCreated").withArgs(address2);
            expect(await newERC1155Contract2.name()).to.be.equal(name2)
            expect(await newERC1155Contract2.symbol()).to.be.equal('TM2')
            expect(await newERC1155Contract2.amountToFinance()).to.be.equal(amountToFinance2)
            expect(await newERC1155Contract2.investmentFractions()).to.be.equal(fractions2)
            expect(await factory.contractsCounter()).to.be.equal(2)
        });

    });
});

describe("Testing FinancingContract", async () => {
    async function loadTest() {
        var [owner, alice, bob, carl, peter] = await ethers.getSigners();

        var USDT = await ethers.getContractFactory("TetherUSD");
        var usdt = await USDT.deploy();
        var addressUSDT = usdt.target;
        
        var name = "ExampleApple";
        var symbol = "BTC";
        var operationAmount = 12000;
        var amountToFinance = 10000;
        var investmentFractions = 10;
        
        var FinancingContract = await ethers.getContractFactory("FinancingContract1155");
        var financing = await FinancingContract.deploy(
            name, symbol, operationAmount, amountToFinance, investmentFractions, addressUSDT, 0
        );

        return { usdt, financing, owner, alice, bob, carl, peter, amountToFinance }
    }

    describe("Testing buyFraction", async () => {
        it("Contract Status", async () => {
            var {usdt, financing} = await loadFixture(loadTest);
            const _status = await financing.readStatus();
            expect(_status).to.be.equal(0);

        });


        it("Amount cannot be zero", async () => {
            var {usdt, financing, owner} = await loadFixture(loadTest);
            await expect(financing.buyFraction(0)).to.be.revertedWith("Amount cannot be zero.");

        });

        it("Amount to buy exceedes total fractions", async () => {
            var {usdt, financing, owner} = await loadFixture(loadTest);
            await expect(financing.buyFraction(12)).to.be.revertedWith("Amount to buy exceeds total fractions.");
        });

        it("Insufficient USDT balance", async () => {
            var {usdt, financing, alice} = await loadFixture(loadTest);
            await expect(financing.connect(alice).buyFraction(1)).to.be.revertedWith("Insufficient USDT balance.");
        });

        it("Allowance", async () => {
            var {usdt, financing, owner, alice} = await loadFixture(loadTest);
            await usdt.mint(alice.address, 100000 * (10**6));
            await expect(financing.connect(alice).buyFraction(1)).to.be.revertedWith("Approve the required amount of USDT.");
        });

        it("Correct Ids, Amounts and Balance", async () => {
            var {usdt, financing, owner, alice, bob, carl} = await loadFixture(loadTest);

            let balance = 5;
            await usdt.approve(financing.target, 20000 * (10**6));
            let tx = await financing.buyFraction(5);

            const _investorBalance = await financing.balanceOf(owner.address, ID);

            await expect(_investorBalance).to.be.equal(balance);
        });

        it("Emit events", async () => {
            var {usdt, financing, owner, alice} = await loadFixture(loadTest);
            await usdt.approve(financing.target, 20000 * (10**6));

            await expect(financing.buyFraction(1)).to.emit(financing, "Invest").withArgs(owner.address, 1);

            await expect(financing.buyFraction(9)).to.emit(financing, "TotalAmountFinanced").withArgs(10000, [owner.address, owner.address]);
        });
    })

    describe("Testing withdrawUSDT", async () => {
        it("Only Admins", async () => {
            var {usdt, financing, owner, alice, bob} = await loadTest();
            // Check that only admins can call the function
            await expect(financing.connect(alice).setBuyBack(10)).to.be.reverted;
        });


        it("Contract Status" ,async () => {
            var {usdt, financing, owner, alice} = await loadFixture(loadTest);
            await usdt.approve(financing.target, 20000 * (10**6));
            await financing.buyFraction(10);
            const _status = await financing.readStatus();
            expect(_status).to.be.equal(1);
        })

        
        it("Emit event", async () => {
            var {usdt, financing, owner} = await loadFixture(loadTest);
            await usdt.approve(financing.target, 20000 * (10**6));
            await financing.buyFraction(10);
            await expect(financing.withdrawUSDT()).to.emit(financing,"WithdrawComplete").withArgs(owner.address, 10000 * (10**6));
        })
    })

    describe("Testing setBuyBack", async () => {
        it("Only Admins", async () => {
            var {usdt, financing, owner, alice, bob} = await loadTest();
            // Check that only admins can call the function
            await expect(financing.connect(alice).setBuyBack(10)).to.be.reverted;
        });

        it("Contract Status", async () => {
            var {usdt, financing, owner} = await loadTest();
            await usdt.approve(financing.target, 20000 * (10**6));
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            const _status = await financing.readStatus();
            expect(_status).to.be.equal(2);
            
        })


        it("Profit can't be zero", async () => {
            var {usdt, financing, owner, alice} = await loadTest();
            await usdt.approve(financing.target, 20000 * (10**6));
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await expect(financing.setBuyBack(0)).to.revertedWith("Profit can't be zero");

        });


        it("Not enough USDT balance", async () => {
            var {usdt, financing, owner, alice} = await loadTest();
            await usdt.approve(financing.target, 20000 * (10**6));
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await expect(financing.setBuyBack(10000)).to.revertedWith("Not enough USDT balance");
        });

        it("Allowance", async () => {
            var {usdt, financing, owner, alice} = await loadTest();
            await usdt.approve(financing.target, 20000 * (10**6));
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await expect(financing.setBuyBack(2000)).to.revertedWith("In order to proceed, you must approve the required amount of USDT.");
        });

        it("Correct amounts", async () => {
            var {usdt, financing, owner, alice, bob} = await loadTest();
            await usdt.approve(financing.target, 25000 * (10**6));
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await financing.setBuyBack(10);
            const buyBackPrice = await financing.readBuyBackPrice();
            expect(buyBackPrice).to.be.equal(1100 * (10**6));
        });


    });

    describe("Testing withdrawBuyBack", async () => {
        it("Contract Status", async () => {
            var {usdt, financing, owner} = await loadTest();
            await usdt.approve(financing.target, 25000 * (10**6));
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await financing.setBuyBack(10);

            const _status = await financing.readStatus();
            expect(_status).to.be.equal(3);
        })

        it("Caller has not tokens", async () => {
            var {usdt, financing, owner, alice} = await loadTest();
            await usdt.approve(financing.target, 25000 * (10**6));
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await financing.setBuyBack(10);
            await expect(financing.connect(alice).withdrawBuyBack()).to.revertedWith("Caller has no tokens.");
        });

        it("Emit event", async () => {
            var {usdt, financing, owner} = await loadTest();
            await usdt.approve(financing.target, 25000 * (10**6));
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await financing.setBuyBack(10);
            let amount = await financing.balanceOf(owner.address, ID);
            await expect(financing.withdrawBuyBack()).to.emit(financing, "BurnNfts").withArgs(ID, amount);
        });

    })



}) 