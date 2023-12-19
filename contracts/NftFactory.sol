// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// ==========---------->>>>>   Librerias para el FACTORY
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import { FinancingContract1155 } from "./NFT1155.sol";


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