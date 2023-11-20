// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// ==========---------->>>>>   Librerias para el FACTORY
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
// ==========---------->>>>>   Librerias para el ERC721
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Factory is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(

    ) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    // Almacenamiento de la informacion del factory
    //mapping (address => address) public financingContractsOwner;

    // Array con todas las direcciones de los contratos creados
    address[] public addressesERC721Created;

    // Emision de los nuevos smart contracts
    function FactoryFunc(
        uint256 _amountToFinance,
        uint256 _investmentFractions
    ) public {
        //address newContract = address(new FinancingContract(_amountToFinance, _investmentFractions));
        address newContract = address(new FinancingContract());
        //financingContractsOwner[newContract] = msg.sender;
    }
}

interface IUSDC {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) external;

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract FinancingContract is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721PausableUpgradeable,
    AccessControlUpgradeable,
    ERC721BurnableUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    uint256 private _nextTokenId;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    //address admin;
    uint256 amountToFinance;
    uint256 investmentFractions;
    uint256 maxFractions;
    uint256 amountFractions;
    uint256 fractionsToWithdraw;
    bool withdraw;
    bool completeCycle;
    address usdcAdd;
    IUSDC usdc;

    mapping(address => bool) public investors;
    mapping(address => bool) public supliers;

    // modifier onlyAdmin() {
    //     require(msg.sender == admin);
    //     _;
    // }

    modifier onlyInvestor() {
        require(investors[msg.sender] == true);
        _;
    }
    modifier onlySuplier() {
        require(supliers[msg.sender] == true);
        _;
    }

    function initialize(
        uint256 _amountToFinance, uint256 _investmentFractions
    ) public initializer {
        __ERC721_init("MyToken", "MTK");
        __ERC721Enumerable_init();
        __ERC721Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    // function initialize(uint256 _amountToFinance, uint256 _investmentFractions, address _admin, address addUsdc) initializer public {
    //     __ERC721_init("MyToken", "MTK");
    //     __ERC721Burnable_init();
    //     __UUPSUpgradeable_init();

    //     usdcAdd = addUsdc;
    //     usdc = IUSDC(usdcAdd);

    //     admin = _admin;

    //     amountToFinance = _amountToFinance;
    //     investmentFractions = _investmentFractions;
    //     amountFractions = amountToFinance / investmentFractions;
    //     maxFractions = investmentFractions;
    // }

    event Invest(address investor, uint256 fractions);
    event TotalAmountFinanced();
    event WithdrawComplete();

    function investAFraction(uint256 _fractions) public onlyInvestor {
        require(_fractions > 0 && _fractions <= investmentFractions);
        require(_nextTokenId < investmentFractions);
        require(usdc.balanceOf(msg.sender) >= _fractions * amountFractions);
        uint amount = amountFractions * _fractions;
        usdc.transferFrom(msg.sender, address(this), amount);

        for (uint256 i = 0; i < _fractions; i++) {
            safeMint(msg.sender, _nextTokenId);
        }

        investmentFractions = investmentFractions - _fractions;
        emit Invest(msg.sender, _fractions);
        if (investmentFractions == 0) {
            withdraw = true;
            emit TotalAmountFinanced(); // completar event
        }
    }

    function enableFractionWithdrawal(uint256 _fractions) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(withdraw == true);
        require(_fractions > 0 && _fractions <= maxFractions);

        fractionsToWithdraw = _fractions;
        maxFractions = maxFractions - _fractions;
    }

    function withdrawInvestment(uint256 _fractions) public onlySuplier {
        require(fractionsToWithdraw > 0);
        require(_fractions > 0 && _fractions <= fractionsToWithdraw);
        require(withdraw == true);

        address supplier = msg.sender;
        uint256 amount = _fractions * amountFractions;
        // aprove?
        transferFrom(address(this), supplier, amount);
        fractionsToWithdraw -= _fractions;
    }

    function withdrawEarnings() public onlyInvestor {
        require(completeCycle == true);
        //Porcentaje de tru market
    }

    function safeMint(address to, uint256 tokenId) public {
        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function adminAddInvestor(address _investor) public onlyRole(DEFAULT_ADMIN_ROLE) {
        investors[_investor] = true;
    }

    function adminAddSupplier(address _suplier) public onlyRole(DEFAULT_ADMIN_ROLE) {
        supliers[_suplier] = true;
    }

    function adminResInvestor(address _investor) public onlyRole(DEFAULT_ADMIN_ROLE) {
        investors[_investor] = false;
    }

    function adminResSupplier(address _suplier) public onlyRole(DEFAULT_ADMIN_ROLE) {
        supliers[_suplier] = false;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721PausableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
