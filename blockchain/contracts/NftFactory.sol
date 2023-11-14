// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Factory is Initializable, ERC721Upgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, UUPSUpgradeable{
    // Almacenamiento de la informacion del factory
    mapping (address => address) public financingContractsOwner;

    // Emision de los nuevos smart contracts
    function Factory(uint256 _amountToFinance, uint256 _investmentFractions ) public {
        address newContract = address(new FinancingContract(_amountToFinance, _investmentFractions));
        financingContractsOwner[newContract] = msg.sender;
    }
}


contract FinancingContract is Initializable, ERC721Upgradeable, ERC721BurnableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    uint256 amountToFinance;
    uint256 investmentFractions;

    function initialize(uint256 _amountToFinance, uint256 _investmentFractions) initializer public {
        __ERC721_init("MyToken", "MTK");
        __ERC721Burnable_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();

        amountToFinance = _amountToFinance;
        investmentFractions = _investmentFractions;
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}