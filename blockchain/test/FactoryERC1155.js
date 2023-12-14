var { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
var { expect } = require("chai");
var { ethers, upgrades } = require("hardhat");

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

        // it("Invest", async () => {
        //     var { factory, usdt, alice } = await loadFixture(loadTest);

        //     let name = 'Contract'
        //     let amountToFinance = 20000
        //     let fractions = 200
        //     let price = (amountToFinance / fractions) * (10 ** 6)
        //     await factory.FactoryFunc(name, amountToFinance, fractions, usdt.target);
        //     let array = await factory.getAddresses()
        //     let address = array[0]
        //     let newERC1155Contract = await getContract(address)
        //     let NFTsAmount = 5
        //     let NFTsPriceInWei = NFTsAmount * price

        //     await usdt.mint(alice, NFTsPriceInWei)
        //     await usdt.connect(alice).approve(newERC1155Contract.target, NFTsPriceInWei)

        //     await newERC1155Contract.connect(alice).buyFraction(NFTsAmount)

        //     expect(await newERC1155Contract.balanceOf(alice.address)).to.be.equal(NFTsAmount)
        //     expect(await usdt.balanceOf(newERC1155Contract.target)).to.be.equal(NFTsPriceInWei)
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
        it("Contract Status", async () => {
            var {usdt, financing} = await loadFixture(loadTest);

            await expect(financing.contractStatus.to.be.equal(financing.Status.onSale));

        });


        it("Price in Wei", async () => {
            var { usdt, financing, owner, alice, bob, carl } = await loadFixture(loadTest);

            await usdt.approve(financing.address, 20000);
            await expect(financing.buyFraction(1).priceInWei.to.be.equal(1000 * (10**6)));

        });


        it("Amount cannot be zero", async () => {
            var {usdt, financing, owner} = await loadFixture(loadTest);
            await expect(financing.buyFraction(0).to.be.revertedWith("Amount cannot be zero."));

        });

        it("Amount to buy exceedes total fractions", async () => {
            var {usdt, financing, owner} = await loadFixture(loadTest);
            await expect(financing.buyFraction(12).to.be.revertedWith("Amount to buy exceedes total fractions."));
        });

        it("Insufficient USDT balance", async () => {
            var {usdt, financing, alice} = await loadFixture(loadTest);
            await expect(financing.connect(alice).buyFraction(1)).to.be.revertedWith("Insufficient USDT balance.");
        });

        it("Allowance", async () => {
            var {usdt, financing, owner, alice} = await loadFixture(loadTest);
            await expect(financing.connect(alice).buyFraction(1).to.be.revertedWith("In order to proceed, you must approve the required amount of USDT."));
        });

        it("Correct Ids, Amounts and Balance", async () => {
            var {usdt, financing, owner, alice, bob, carl} = await loadFixture(loadTest);
            let ids = [0,1,2,3,4];
            let amounts = [1,1,1,1,1];
            let balance = 5;
            await usdt.approve(financing.address, 20000);
            let tx = await financing.buyFraction(5);

            await expect(financing.investorIds[owner.address].to.be.equal(ids));
            await expect(financing.investorAmounts[owner.address].to.be.equal(amounts));
            await expect(financing.investorBalances[owner.address].to.be.equal(balance));
        });

        it("Emit events", async () => {
            var {usdt, financing, owner, alice} = await loadFixture(loadTest);
            await usdt.approve(financing.address, 20000);

            await expect(financing.buyFraction(1).to.emit(financing, "Invest").withArgs(owner.address, 1));

            await expect(financing.buyFraction(9).to.emit(financing, "TotalAmountFinanced"));
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
            await usdt.approve(financing.address, 20000);
            await financing.buyFraction(10);
            expect(financing.contractStatus.to.be.equal(financing.Status.Sold));
        })

        
        it("Emit event", async () => {
            var {usdt, financing, owner} = await loadFixture(loadTest);
            await usdt.approve(financing.address, 20000);
            await financing.buyFraction(10);
            await expect(financing.withdrawUSDT()).to.emit(financing,"WithdrawComplete");
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
            await usdt.approve(financing.address, 20000);
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            expect(financing.contractStatus.to.be.equal(financing.Status.Milestones));
            
        })


        it("Profit can't be zero", async () => {
            var {usdt, financing, owner, alice} = await loadTest();
            await usdt.approve(financing.address, 20000);
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await expect(financing.setBuyBack(0)).to.revertedWith("Profit can't be zero");

        });


        it("Not enough USDT balance", async () => {
            var {usdt, financing, owner, alice} = await loadTest();
            await usdt.approve(financing.address, 20000);
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await expect(financing.connect(alice).setBuyBack(10)).to.revertedWith("Not enough USDT balance");
        });

        it("Allowance", async () => {
            var {usdt, financing, owner, alice} = await loadTest();
            await usdt.approve(financing.address, 20000);
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await usdt.mint(alice.address, 100000);
            await expect(financing.connect(alice).setBuyBack(10)).to.revertedWith("In order to proceed, you must approve the required amount of USDT.");
        });

        it("Correct amounts", async () => {
            var {usdt, financing, owner, alice, bob} = await loadTest();
            await usdt.approve(financing.address, 20000);
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            let tx = await financing.setBuyBack(10);
            expect(financing.buyBackPrice.to.be.equal(1100 * (10**6)));
        });


    });

    describe("Testing withdrawBuyBack", async () => {
        it("Contract Status", async () => {
            var {usdt, financing, owner} = await loadTest();
            await usdt.approve(financing.address, 20000);
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await financing.setBuyBack(10);

            expect(financing.Status.to.be.equal(financing.Status.Finished));
        })

        it("Caller has not tokens", async () => {
            var {usdt, financing, owner} = await loadTest();
            await usdt.approve(financing.address, 20000);
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await financing.setBuyBack(10);
            await expect(financing.connect(alice).withdrawBuyBack().to.revertedWith("Caller has not tokens"));
        });

        it("Emit event", async () => {
            var {usdt, financing, owner} = await loadTest();
            await usdt.approve(financing.address, 20000);
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await financing.setBuyBack(10);
            let args = [0,1,2,3,4,5,6,7,8,9];
            await expect(financing.withdrawBuyBack().to.emit(financing, "BurnNfts").withArgs(args));
        });

        it("Delete balances", async () => {
            var {usdt, financing, owner} = await loadTest();
            await usdt.approve(financing.address, 20000);
            await financing.buyFraction(10);
            await financing.withdrawUSDT();
            await financing.setBuyBack(10);
            await financing.withdrawBuyBack();

            expect(financing.investorIds[owner.address].to.be.equal(0));
            expect(financing.investorAmounts[owner.address].to.be.equal(0));
            expect(financing.investorBalances[owner.address].to.be.equal(0));
        })
    })


}) 