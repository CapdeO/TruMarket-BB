// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// ==========---------->>>>>   Librerias para el FACTORY
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// ==========---------->>>>>   Librerias para el ERC721
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract Factory is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    /* ========== STATE VARIABLES ========== */

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // Cantidad de contratos creados hasta el momento
    uint256 public contractsCounter;

    // Array con todas las direcciones de los contratos creados
    address[] public addressesERC721Created;

    /* ========== Events ========== */

    event NewContractDeployed(address indexed deployedContract);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
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

    // Emision de los nuevos smart contracts
    function FactoryFunc(
        //uint256 _amountToFinance,
        //uint256 _investmentFractions,
        address _addUsdc
    ) public returns (address) {
        contractsCounter += 1;

        string memory name = "nombre";
        string memory symbol = string(
            abi.encodePacked("TM", Strings.toString(contractsCounter))
        );
        uint256 _amountToFinance = 10000;
        uint256 _investmentFractions = 5;

        FinancingContract newContract = new FinancingContract();
        newContract.initialize(
            name,
            symbol,
            _amountToFinance,
            _investmentFractions,
            _addUsdc
        );

        return address(newContract);
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

contract FinancingContractUp is
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

    modifier onlyInvestor() {
        require(investors[msg.sender] == true);
        _;
    }
    modifier onlySuplier() {
        require(supliers[msg.sender] == true);
        _;
    }

    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _amountToFinance,
        uint256 _investmentFractions,
        address _addUsdc
    ) public initializer {
        __ERC721_init(_name, _symbol);
        __ERC721Enumerable_init();
        __ERC721Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();
        __UUPSUpgradeable_init();

        usdc = IUSDC(_addUsdc);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

        amountToFinance = _amountToFinance;
        investmentFractions = _investmentFractions;
        amountFractions = amountToFinance / investmentFractions;
        maxFractions = investmentFractions;
    }

    event Invest(address investor, uint256 fractions);
    event TotalAmountFinanced();
    event WithdrawComplete();

    function investAFraction(uint256 _fractions) public onlyInvestor {
        require(_fractions > 0 && _fractions <= investmentFractions);
        require(_nextTokenId < investmentFractions);
        require(usdc.balanceOf(msg.sender) >= _fractions * amountFractions);
        uint amount = amountFractions * _fractions;
        require(
            usdc.allowance(msg.sender, address(this)) >= amount,
            "You must approbe the amount first."
        );
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

    uint256[] public milestones;
    // // [20, 20, 10, 30, 50, 40]
    // // 0    1   2   3  4   5

    // mapping (uint256 => uint256) milestones;

    uint256 actualMilestone;

    // uint256 milestone;
    // uint256 actualMilestone;
    // function que libere los pagos del milestone actual

    // cuando se llama la funcion que libera el pago del milestone actual
    // envia el porcentaje de USDT a la address del exportador
    // aumenta actualMilestone +1

    function payMilestone() public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(withdraw == true);
        //uint256 pay = (amountToFinance * milestones[actualMilestone]) / 100;
        //require(usdc.balanceOf(address(this)) >= pay);
        //usdc.transfer(supplier, pay);
        actualMilestone++;
    }

    // function enableFractionWithdrawal(uint256 _fractions) public onlyRole(DEFAULT_ADMIN_ROLE) {
    //     require(withdraw == true);
    //     require(_fractions > 0 && _fractions <= maxFractions);

    //     fractionsToWithdraw = _fractions;
    //     maxFractions = maxFractions - _fractions;
    // }

    // function withdrawInvestment(uint256 _fractions) public onlySuplier {
    //     require(fractionsToWithdraw > 0);
    //     require(_fractions > 0 && _fractions <= fractionsToWithdraw);
    //     require(withdraw == true);

    //     address supplier = msg.sender;
    //     uint256 amount = _fractions * amountFractions;
    //     // aprove?
    //     transferFrom(address(this), supplier, amount);
    //     fractionsToWithdraw -= _fractions;
    // }

    // function withdrawEarnings() public onlyInvestor {
    //     require(completeCycle == true);
    //     //Porcentaje de tru market
    // }

    function safeMint(address to, uint256 tokenId) public {
        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function adminAddInvestor(
        address _investor
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        investors[_investor] = true;
    }

    function adminAddSupplier(
        address _suplier
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        supliers[_suplier] = true;
    }

    function adminResInvestor(
        address _investor
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        investors[_investor] = false;
    }

    function adminResSupplier(
        address _suplier
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    )
        internal
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            ERC721PausableUpgradeable
        )
        whenNotPaused
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            AccessControlUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}


contract FinancingContract is 
    ERC721, ERC721Enumerable, 
    ERC721Pausable, 
    AccessControl, 
    ERC721Burnable 
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address defaultAdmin, address pauser, address minter)
        ERC721("MyToken", "MTK")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(address to, uint256 tokenId) public onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
