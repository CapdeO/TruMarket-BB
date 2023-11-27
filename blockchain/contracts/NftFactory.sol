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
        string memory _name,
        uint256 _amountToFinance,
        uint256 _investmentFractions,
        address _addUsdc
    ) public returns (address) {
        contractsCounter += 1;

        string memory _symbol = string(
            abi.encodePacked("TM", Strings.toString(contractsCounter))
        );

        FinancingContract newContract = new FinancingContract(
            _name,
            _symbol,
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

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract FinancingContract is
    ERC721,
    ERC721Enumerable,
    ERC721Pausable,
    AccessControl,
    ERC721Burnable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 private _nextTokenId;

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

    event Invest(address investor, uint256 fractions);
    event TotalAmountFinanced();
    event WithdrawComplete();
    event newMilestone(uint256 step, string description);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _amountToFinance,
        uint256 _investmentFractions,
        address _addUsdc
    ) ERC721(_name, _symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

        usdc = IUSDC(_addUsdc);

        amountToFinance = _amountToFinance;
        investmentFractions = _investmentFractions;
        amountFractions = amountToFinance / investmentFractions;
        maxFractions = investmentFractions;
    }

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

    function safeMint(address to, uint256 tokenId) public {
        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function burnNft(uint256 tokenId, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(tokenId);
        transferFrom(address(this), msg.sender, amount);
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

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
