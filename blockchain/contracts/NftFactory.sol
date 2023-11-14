// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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
    uint256 private _nextTokenId;
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    uint256 amountToFinance;
    uint256 investmentFractions;
    uint256 amountFractions = amountToFinance / investmentFractions;

    function initialize(uint256 _amountToFinance, uint256 _investmentFractions) initializer public {
        __ERC721_init("MyToken", "MTK");
        __ERC721Burnable_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();

        amountToFinance = _amountToFinance;
        investmentFractions = _investmentFractions;
    }

    event Invest (address investor, uint256 fractions);

    function investAFraction(uint256 _fractions) public payable {
        require(_fractions > 0 && fractions <= investmentFractions);
        require(_nextTokenId < investmentFractions);
        transfer(address(this), amountFractions * _fractions);

        for (uint256 i = 0; i <_fractions; i++){
            safeMint(msg.sender);
            }

        investmentFractions = investmentFractions - _fractions;
        emit Invest(msg.sender, _fractions);
    }

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}