// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// ==========---------->>>>>   Libraries for FACTORY
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// ==========---------->>>>>   Libraries for ERC1155
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

/**
 * @title Factory
 * @dev Contract that acts as a factory for creating financing contracts.
 * Uses OpenZeppelin for Pausable, Access Control, and UUPSUpgradeable functionalities.
 */
contract Factory is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    /* ========== STATE VARIABLES ========== */

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    uint256 public contractsCounter; // Counter for created contracts
    address[] private addressesERC1155Created; // Array that stores addresses of created contracts

    /* ========== Events ========== */

    event ContractCreated(address indexed deployedContract);

    /* ========== Constructor and Initialization ========== */

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializes the contract by assigning roles and permissions to the admin.
     */
    function initialize() public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    /* ========== State Changing Functions ========== */

    /**
     * @dev Pauses the contract, can only be executed by the PAUSER_ROLE.
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses the contract, can only be executed by the PAUSER_ROLE.
     */
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev Internal function to authorize the upgrade, can only be executed by the UPGRADER_ROLE.
     * @param newImplementation The new implementation address.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

    /**
     * @dev Factory function that creates a new financing contract.
     * @param _name Contract name.
     * @param _operationAmount Total amount of the operation.
     * @param _amountToFinance Amount to finance.
     * @param _investmentFractions Number of fractions.
     * @param _addUsdc Address of the USDT contract.
     * @return The address of the newly created contract.
     */
    function FactoryFunc(
        string memory _name,
        uint256 _operationAmount,
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
            _operationAmount,
            _amountToFinance,
            _investmentFractions,
            _addUsdc,
            contractsCounter
        );

        address newContractAdd = address(newContract);
        addressesERC1155Created.push(newContractAdd); // Store the new address in the array
        emit ContractCreated(newContractAdd); // Emit the event
        return newContractAdd; // Return the address of the new contract
    }

    /* ========== View Functions ========== */

    /**
     * @dev Returns the addresses of the created contracts.
     * @return An array with the addresses of the created contracts.
     */
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


/**
 * @title FinancingContract1155
 * @dev ERC1155 contract with functionalities for fractional investments.
 */
contract FinancingContract1155 is ERC1155, ERC1155Pausable, AccessControl, ERC1155Burnable {
    
    /* ========== STATE VARIABLES ========== */

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    string  public   name;                 // Collection name
    string  public   symbol;               // Identifier symbol
    uint256 public   ID;                   // NFT IDs
    uint256 public   operationAmount;      // Total operation amount
    uint256 public   amountToFinance;      // Total amount to finance
    uint256 public   investmentFractions;  // Total number of fractions
    uint256 public   fractionPrice;        // Price of each fraction
    uint256 public   buyBackPrice;         // Value of each fraction including profit
    uint256 public   investedFractions;    // Fractions already purchased
    address[] public investors;            // Ivestors
    IUSDT            usdt;                 // USDT Tether interface

    function readBuyBackPrice() public view returns (uint256) {
        return buyBackPrice;
    }

    /**
     * @dev Struct to store purchase history.
     */
    struct HistoryFractions {
        uint256 fractions; // Fractions purchased
        uint256 timestamp; // Purchase date and time
        address owner;     // Buyer's address
    }

    // Array to store purchase history (stores the struct)
    HistoryFractions[] public historyFractions;

    /**
     * @dev Enumerable representing the state of the contract.
     */
    enum Status {
        OnSale,     // Available for sale
        Sold,       // Sold
        Milestones, // Supplier's milestones in progress
        Finished    // Contract finished, ready for investors to withdraw profits
    }

    Status public contractStatus; // Current contract state

    function readStatus() public view returns (Status) {
        return contractStatus;
    }

    /* ========== EVENTS ========== */

    event Invest(address investor, uint256 fractions); // Investment or purchase made
    event TotalAmountFinanced(uint256 amount, address[] investors); // Total amount financed
    event WithdrawComplete(address admin, uint256 amount); // Withdrawal of total amount completed
    event BurnNfts(uint256 tokenId, uint256 amount); // NFTs burned

    /**
     * @dev Contract constructor.
     * @param _name Collection name.
     * @param _symbol Identifier symbol.
     * @param _operationAmount Total operation amount.
     * @param _amountToFinance Total amount to finance.
     * @param _investmentFractions Total number of fractions.
     * @param _addUsdt USDT Tether contract address.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _operationAmount,
        uint256 _amountToFinance,
        uint256 _investmentFractions,
        address _addUsdt,
        uint256 _id
    ) ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        usdt = IUSDT(_addUsdt);

        name = _name;
        symbol = _symbol;
        operationAmount = _operationAmount;
        amountToFinance = _amountToFinance;
        investmentFractions = _investmentFractions;
        fractionPrice = amountToFinance / investmentFractions;
        ID = _id;

        contractStatus = Status.OnSale;
    }

    /**
     * @dev Function executed by investors to buy fractions.
     * @param _amount Amount of fractions to buy.
     */
    function buyFraction(uint256 _amount) public whenNotPaused {
        // Convert price to wei (six decimals)
        uint256 priceInWei = (fractionPrice * (10**6)) * _amount;
        // Ensure the contract is in the "OnSale" state
        require(contractStatus == Status.OnSale, "The sale is closed.");
        // Ensure the amount to invest is greater than 0
        require(_amount > 0, "Amount cannot be zero.");
        // Ensure the amount to buy does not exceed the total fractions
        require(_amount <= (investmentFractions - investedFractions), "Amount to buy exceeds total fractions.");
        // Check if the buyer's balance is sufficient for the purchase
        require(usdt.balanceOf(msg.sender) >= priceInWei, "Insufficient USDT balance.");
        // Check if the contract has permission to use the buyer's funds
        require(usdt.allowance(msg.sender, address(this)) >= priceInWei, "Approve the required amount of USDT.");
        // Transfer funds to the contract and verify the transaction
        require(usdt.transferFrom(msg.sender, address(this), priceInWei), "USDT transfer error.");

        // MINT IN BLOCKS
        _mint(msg.sender, ID, _amount, "");

        // Emit the event
        emit Invest(msg.sender, _amount);

        investors.push(msg.sender);

        // Check if all fractions have been sold; if so, change the contract status and emit the event
        investedFractions += _amount;
        if (investedFractions == investmentFractions){
            contractStatus = Status.Sold;
            emit TotalAmountFinanced(amountToFinance, investors);
        }

        // Store data in the fractions purchase history
        uint256 fractions = _amount;
        uint256 timestamp = block.timestamp;
        address owner = msg.sender;

        // Store data in the fractions purchase history
        historyFractions.push(HistoryFractions(fractions, timestamp, owner));
    }

    /**
     * @dev Function executed by Admins to withdraw financed amounts.
     */
    function withdrawUSDT() public onlyRole(DEFAULT_ADMIN_ROLE) {
        // Calculate the contract's USDT balance
        uint256 contractBalance = usdt.balanceOf(address(this));
        // Ensure the contract status is "Sold"
        require(contractStatus == Status.Sold, "Not on sold status.");
        // Transfer funds from the contract to the admin and verify the transaction
        require(usdt.transfer(msg.sender, contractBalance), "USDT transfer error.");
        // Change the contract status to Milestones
        contractStatus = Status.Milestones;
        // Emit the event
        emit WithdrawComplete(msg.sender, contractBalance);
    }

/**
 * @dev Financing and BuyBack Mechanism
 * @dev Allows the Admin to inject financed amount plus profit into the contract and enables profit withdrawal for investors.
 */
function setBuyBack(uint256 profit) public onlyRole(DEFAULT_ADMIN_ROLE) {
    // Ensures the contract is in the "Milestones" status
    require(contractStatus == Status.Milestones, "Invalid status for Buyback.");
    // Ensures profit is greater than 0
    require(profit > 0, "Profit can't be zero");
    // Calculates the total amount including profit to be injected
    uint256 totalAmount = amountToFinance + ((amountToFinance * profit) / 100);
    totalAmount = totalAmount * (10**6);
    // Ensures Admin has a sufficient balance
    require(totalAmount <= usdt.balanceOf(msg.sender), "Not enough USDT balance");
    // Ensures the contract is allowed to use Admin's funds
    require(usdt.allowance(msg.sender, address(this)) >= totalAmount, 
        "In order to proceed, you must approve the required amount of USDT.");
    // Transfers funds to the contract
    require(usdt.transferFrom(msg.sender, address(this), totalAmount), "USDT transfer error.");
    // Calculates the value of fractions plus profit
    buyBackPrice = fractionPrice + ((fractionPrice * profit) / 100);
    buyBackPrice = buyBackPrice * (10**6);
    // Changes the contract status to Finished
    contractStatus = Status.Finished;
}

/**
 * @dev Allows investors to withdraw profits after the contract is Finished.
 */
function withdrawBuyBack() whenNotPaused public {
    // Ensures the contract status is "Finished"
    require(contractStatus == Status.Finished, "Contract is not finished.");

    uint256 nftsAmount = balanceOf(msg.sender, ID);
    // Ensures the value is greater than 0
    require(nftsAmount > 0, "Caller has no tokens.");
    // Calculates the total amount to be withdrawn
    uint256 totalAmount = nftsAmount * buyBackPrice;
    // Burns NFTs in blocks
    _burn(msg.sender, ID, nftsAmount);
    // Emits the event
    emit BurnNfts(ID, nftsAmount);
    // Transfers the money to their wallet
    require(usdt.transfer(msg.sender, totalAmount), "USDT transfer error.");
}

/**
 * @dev Public view function to review the history of purchases made.
 */
function getHistorial() public view returns (HistoryFractions[] memory) {
    return historyFractions;
}

// Pauses the contract
function pause() public onlyRole(PAUSER_ROLE) {
    _pause();
}

// Unpauses the contract
function unpause() public onlyRole(PAUSER_ROLE) {
    _unpause();
}

/**
 * @dev Overrides supportsInterface to check ERC1155 and AccessControl interfaces.
 */
function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC1155, AccessControl)
    returns (bool)
{
    return super.supportsInterface(interfaceId);
}

/**
 * @dev Overrides _beforeTokenTransfer to check ERC1155 and ERC1155Pausable interfaces.
 */
function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    internal
    override(ERC1155, ERC1155Pausable)
{
    super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

}