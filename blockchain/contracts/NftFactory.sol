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
    address[] private addressesERC721Created;
    // Mapping de profit de cada contrato finalizado
    mapping(address => uint256) public profits;

    /* ========== Events ========== */

    event NewContractDeployed(address indexed deployedContract);

    /* ========== Constructor ========== */

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

    /* ========== Change state ========== */

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

        address newContractAdd = address(newContract);

        addressesERC721Created.push(newContractAdd);
        emit NewContractDeployed(newContractAdd);
        return newContractAdd;
    }

    /* ========== View functions ========== */

    function getAddresses() public view returns(address[] memory) {
        return addressesERC721Created;
    }
}

interface IUSDT {
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
    AccessControl
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 private _nextTokenId;

    uint256 public amountToFinance;
    uint256 public investmentFractions;
    uint256 public fractionPrice;
    bool withdraw;
    IUSDT usdt;

    mapping (uint256 => address) investors;

    enum Status {
        OnSale,
        Sold,
        Milestones,
        Finished
    }
    Status public contractStatus;

    event Invest(address investor, uint256 fractions);
    event TotalAmountFinanced();
    event WithdrawComplete();
    event newMilestone(uint256 step, string description);
    event BurnNft(uint256 tokenId);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _amountToFinance,
        uint256 _investmentFractions,
        address _addUsdt
    ) ERC721(_name, _symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        usdt = IUSDT(_addUsdt);

        amountToFinance = _amountToFinance;
        investmentFractions = _investmentFractions;
        fractionPrice = amountToFinance / investmentFractions;

        safeMintBatch(_investmentFractions);
    }

    function safeMintBatch(uint256 _amount) internal {
        require(_amount > 0, 'Amount cannot be zero.');
        for (uint8 i=0; i<_amount; i++) 
            _safeMint(address(this), i);
    }

    function buyFraction(uint256 _amount) public whenNotPaused {
        // Se realizan las comprobaciones.
        uint256 priceInWei = (fractionPrice * (10**6)) * _amount;
        require(contractStatus == Status.OnSale, "La compra esta cerrada.");
        require(_amount > 0, "Amount cannot be zero.");
        require(_amount < investmentFractions, "Amount to buy exceedes total fractions.");
        require(usdt.balanceOf(msg.sender) >= priceInWei, 
            "Inssuficient USDT balance.");
        require(usdt.allowance(msg.sender, address(this)) >= priceInWei, 
            "In order to proceed, you must approve the required amount of USDT.");
        require(usdt.transferFrom(msg.sender, address(this), priceInWei), 
            "USDT transfer error.");
        require(_amount <= balanceOf(address(this)));

        // Se transfiere los NFT al inversor y este le da el approve al contrato.
        for (uint8 i=0; i<_amount; i++){
            safeTransferFrom(address(this), msg.sender, _nextTokenId);
            // emit Transfer(address(this), msg.sender, _nextTokenId);
            approve(address(this), _nextTokenId);
            // emit Approval(msg.sender, address(this), _nextTokenId);
        // Update variables
        investors[_nextTokenId] = msg.sender;
        _nextTokenId++;
        }

        emit Invest(msg.sender, _amount);

        if (balanceOf(address(this)) == 0)
            contractStatus = Status.Sold;
    }

    function buyBack(uint256 profit) public onlyRole(DEFAULT_ADMIN_ROLE) {
        // Comprobaciones
        require(profit > 0, "Profit can't be zero");
        uint256 totalAmount = amountToFinance + ((amountToFinance * profit) / 100);
        totalAmount = totalAmount * (10**6);
        require(totalAmount <= usdt.balanceOf(msg.sender), "Admin does not have enough USDT balance");
        // El admin transfiere el monto total a devolver mas el profit
        usdt.transfer(address(this), totalAmount);
        // Se calcula el valor de cada fraccion mas su profit
        uint256 pay = fractionPrice + ((fractionPrice * profit) / 100);
        // Se transfieren los NFT desde los inversores hacia el contrato y se queman.
        // Y se le paga a su respectivo inversor el valor de la fraccion mas el profit.
        for (uint256 i=0; i<investmentFractions; i++){
            safeTransferFrom(investors[i], address(this), i);
            emit Transfer(investors[i], address(this), i);
            _burn(i);
            emit BurnNft(i);
            usdt.transferFrom(address(this), investors[i], pay);
        }
    }

    function withdrawUSDT() public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 contractBalance = usdt.balanceOf(address(this));
        require(contractStatus == Status.Sold, "Sale is open.");
        require(contractBalance > 0, "Contract without balance");
        require(usdt.transfer(msg.sender, contractBalance), "USDT transfer error.");
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

// Pendientes:

// - Override de funciones transfer para evitar que envien tokens
// - Cambio de Status cuando se venden todas las fractions (Sold)            -----> Done
// - Cambio de estado cuando el admin retira el monto financiado (Milestones)-----> Done
// - Cambio de estado cuando el admin hace el buyBack (Finished)
// - Ver calculo variable pay en buyBack