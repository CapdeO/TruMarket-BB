var { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
var { expect } = require("chai");
var { ethers, upgrades } = require("hardhat");

describe("Testeando NFTFactory", () => {
    async function loadTest() {
        var [owner, alice, bob, carl] = await ethers.getSigners();
        var USDT = await ethers.getContractFactory("TetherUSD");
        var usdt = await USDT.deploy();
        let usdtAddress = usdt.target;
        var Factory = await ethers.getContractFactory("Factory");
        var factory = await upgrades.deployProxy(Factory, [
    
        ], { initializer: 'initialize', kind: 'uups' });
        
        return { factory, usdt, owner, alice, bob, carl };
    }

    describe("deploy", () => {
        it("deploy", async () => {
            var { factory, owner } = await loadFixture(loadTest);

            let symbol = await factory.FactoryFunc()

            console.log('symbol: ', symbol)
        });

    });

});