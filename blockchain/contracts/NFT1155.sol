// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// ==========---------->>>>>   Librerias para el FACTORY
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// ==========---------->>>>>   Librerias para el ERC1155
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
// import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Factory is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    /* ========== STATE VARIABLES ========== */

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    uint256 public contractsCounter;
    address[] private addressesERC1155Created;
    mapping(address => uint256) public profits;

    // Struct con financiacion, profits

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

    // Minimal proxy --> clones de smart contracts menor costo EIP-1167
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

        FinancingContract1155 newContract = new FinancingContract1155(
            _name,
            _symbol,
            _amountToFinance,
            _investmentFractions,
            _addUsdc
        );

        address newContractAdd = address(newContract);

        addressesERC1155Created.push(newContractAdd);
        emit NewContractDeployed(newContractAdd);
        return newContractAdd;
    }

    /* ========== View functions ========== */

    function getAddresses() public view returns(address[] memory) {
        return addressesERC1155Created;
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

contract FinancingContract1155 is ERC1155, ERC1155Pausable, AccessControl, ERC1155Burnable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 private _nextTokenId;

    uint256 public amountToFinance;
    uint256 public investmentFractions;
    uint256 public fractionPrice;
    uint256 public buyBackPrice;
    bool withdraw;
    IUSDT usdt;

    struct HistoryFractions {
        uint256 fractions;
        uint256 timestamp;
        address owner;
    }

    HistoryFractions[] public historyFractions;

    mapping (uint256 => address) investors;
    mapping (address=>uint256) investorBalances;
    mapping (address => uint256[]) investorIds;
    mapping (address => uint256[]) investorAmounts;

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
        ) ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        usdt = IUSDT(_addUsdt);

        amountToFinance = _amountToFinance;
        investmentFractions = _investmentFractions;
        fractionPrice = amountToFinance / investmentFractions;
    }

    function buyFraction(uint256 _amount) public whenNotPaused {
        uint256 priceInWei = (fractionPrice * (10**6)) * _amount;
        require(contractStatus == Status.OnSale, "The sale is closed.");
        require(_amount > 0, "Amount cannot be zero.");
        require(_amount < investmentFractions + 1, "Amount to buy exceedes total fractions.");
        require(usdt.balanceOf(msg.sender) >= priceInWei, 
            "Inssuficient USDT balance.");
        require(usdt.allowance(msg.sender, address(this)) >= priceInWei, 
            "In order to proceed, you must approve the required amount of USDT.");
        require(usdt.transferFrom(msg.sender, address(this), priceInWei), 
            "USDT transfer error.");


        // SE ARMAN LOS ARRAY PARA REALIZAR EL MINTEO EN BLOQUES
        // SE ALMACENAN LOS DATOS DEL TOKEN EN LOS MAPPING DEL INVERSOR
        uint256[] memory _ids = new uint256[](_amount);
        uint256[] memory _amounts = new uint256[](_amount);
        for (uint8 i=0; i<_amount; i++) {
            _ids[i] = _nextTokenId;
            investorIds[msg.sender].push(_nextTokenId);
            _amounts[i] = 1;
            investorAmounts[msg.sender].push(1);
            _nextTokenId++;
        }

        // MINT EN BLOQUES
        _mintBatch(msg.sender, _ids, _amounts,"");

        emit Invest(msg.sender, _amount);

        if (_nextTokenId == (investmentFractions + 1)){
            contractStatus = Status.Sold;
        }

        uint256 fractions = _amount;
        uint256 timestamp = block.timestamp;
        address owner = msg.sender;

        historyFractions.push(HistoryFractions(fractions, timestamp, owner));
    }

    function setBuyBack(uint256 profit) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(profit > 0, "Profit can't be zero");

        uint256 totalAmount = amountToFinance + ((amountToFinance * profit) / 100);

        totalAmount = totalAmount * (10**6);

        require(totalAmount <= usdt.balanceOf(msg.sender), "Not enough USDT balance");

        require(usdt.allowance(msg.sender, address(this)) >= totalAmount, 
            "In order to proceed, you must approve the required amount of USDT.");

        usdt.transferFrom(msg.sender, address(this), totalAmount);

        buyBackPrice = fractionPrice + ((fractionPrice * profit) / 100);

        contractStatus = Status.Finished;
    }

    function withdrawBuyBack() public {
        require(contractStatus == Status.Finished, "Contract is not finished.");
        require(investorIds[msg.sender].length == investorAmounts[msg.sender].length);
        uint256 nftsAmount = investorIds[msg.sender].length;
        require(nftsAmount > 0, "Caller has not tokens.");

        uint256 totalAmount = nftsAmount * buyBackPrice;
        // QUEMA EN BLOQUES
        _burnBatch(msg.sender, investorIds[msg.sender], investorAmounts[msg.sender]);
        delete investorIds[msg.sender];
        delete investorAmounts[msg.sender];
        usdt.transfer(msg.sender, totalAmount);
    }

    function withdrawUSDT() public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 contractBalance = usdt.balanceOf(address(this));
        require(contractStatus == Status.Sold, "Not on sold status.");
        require(usdt.transfer(msg.sender, contractBalance), "USDT transfer error.");
        contractStatus = Status.Milestones;
    }

    function getHistorial() public view returns (HistoryFractions[] memory) {
        return historyFractions;
    }

        function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // The following functions are overrides required by Solidity.

    // function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
    //     internal
        // override(ERC1155, ERC1155Pausable)
    // {
    //     super._update(from, to, ids, values);
    // }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

        function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Pausable)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }


}