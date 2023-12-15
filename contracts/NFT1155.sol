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

contract Factory is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    /* ========== STATE VARIABLES ========== */

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    uint256 public contractsCounter; // Contador de contratos creados
    address[] private addressesERC1155Created; // Array que almacena las addresses de los contratos creados

    /* ========== Events ========== */

    event ContractCreated(address indexed deployedContract);

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

    // Funcion Factory que crea un nuevo contrato de financiacion
    function FactoryFunc(
        string memory _name,
        uint256 _operationAmount,      // Monto total de la operacion
        uint256 _amountToFinance,      // Monto a financiar
        uint256 _investmentFractions,  // Cantidad de fracciones
        address _addUsdc               // Address USDT
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
            _addUsdc
        );

        address newContractAdd = address(newContract);
        addressesERC1155Created.push(newContractAdd);  // Almacena el nuevo address en el array
        emit ContractCreated(newContractAdd);          // Se emite el evento
        return newContractAdd;                         // Retorna el address del nuevo contrato
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
    
    /* ========== STATE VARIABLES ========== */

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    string  public   name;                 // Nombre de la coleccion
    string  public   symbol;               // Symbolo de identificacion
    uint256 public   ID = 420;             // Id de los NFTs
    uint256 public   operationAmount;      // Monton total de operacion
    uint256 public   amountToFinance;      // Monto total a financiar
    uint256 public   investmentFractions;  // Cantidad de fracciones totales 
    uint256 public   fractionPrice;        // Precio de cada fraccion
    uint256 public   buyBackPrice;         // Valor de cada fraccion sumando el profit
    uint256 public   investedFractions;    // Fracciones ya compradas
    IUSDT            usdt;                 // Interfaz de USDT Tether

    function readBuyBackPrice() public view returns (uint256) {
        return buyBackPrice;
    }

    // Estructura que almacena el historial de compras realizadas
    struct HistoryFractions {
        uint256 fractions; // Fracciones compradas
        uint256 timestamp; // Fecha y hora de la compra
        address owner; // Address del comprador
    }

    // Array que almacena el historial de compras realizadas (almacena el struct)
    HistoryFractions[] public historyFractions;


    // Enumerable que representa el estado en el que se encuentra el contrato
    enum Status {
        OnSale,     // En venta
        Sold,       // Vendido
        Milestones, // En proceso de despacho de los proveedores
        Finished    // Contrato finalizado, listo para que los inversores retiren las ganancias
    }

    Status public contractStatus; // Estado actual correspondiente al contrato

    function readStatus() public view returns (Status) {
        return contractStatus;
    }

    /* ========== EVENTS ========== */

    event Invest(address investor, uint256 fractions); // Inversion o compra realizada
    event TotalAmountFinanced(); // Monto total financiado
    event WithdrawComplete(); // Retiro del monto total completado
    event BurnNfts(uint256 tokenId, uint256 amount); // NFTs quemados

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _operationAmount,
        uint256 _amountToFinance,
        uint256 _investmentFractions,
        address _addUsdt
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

        contractStatus = Status.OnSale;
    }

    // Funcion que ejecutan los inversores para comprar fracciones

    function buyFraction(uint256 _amount) public whenNotPaused {
        // Le agrega los seis decimales
        uint256 priceInWei = (fractionPrice * (10**6)) * _amount;
        // Verifica que el contrato este en el estado de venta o "OnSale"
        require(contractStatus == Status.OnSale, "The sale is closed.");
        // Verifica que la cantidad de fracciones a invertir sea mayor a 0
        require(_amount > 0, "Amount cannot be zero.");
        // Verifica que la cantidad de fracciones a comprar sea menor al total
        require(_amount <= (investmentFractions - investedFractions), "Amount to buy exceedes total fractions.");
        // Verifica que el balance del comprador sea suficiente para la compra
        require(usdt.balanceOf(msg.sender) >= priceInWei, 
            "Insufficient USDT balance.");
        // Verifica que el contrato tenga permiso de utilizar los fondos del comprador
        require(usdt.allowance(msg.sender, address(this)) >= priceInWei, 
            "In order to proceed, you must approve the required amount of USDT.");
        // Realiza la transferencia de los fondos hacia el contrato y verifica que la transaccion sea exitosa
        require(usdt.transferFrom(msg.sender, address(this), priceInWei), 
            "USDT transfer error.");

        // MINT EN BLOQUES
        _mint(msg.sender, ID, _amount,"");

        // Se emite el evento
        emit Invest(msg.sender, _amount);

        // Verifica si se han vendido todas las fracciones, en ese caso cambia el estado del contrato y emite el evento
        investedFractions += _amount;
        if (investedFractions == (investmentFractions)){
            contractStatus = Status.Sold;
            emit TotalAmountFinanced();
        }

        // Completa los datos para almacenar en el historial de compras de fracciones
        uint256 fractions = _amount;
        uint256 timestamp = block.timestamp;
        address owner = msg.sender;

        // Almacena los datos en el historial de compra de fracciones
        historyFractions.push(HistoryFractions(fractions, timestamp, owner));
    }

    // function buyFraction2(uint256[] memory _ids, uint256[] memory _amount) public whenNotPaused {
    //     // Cantidad a comprar
    //     uint256 amount = _amount.length;
    //     // Le agrega los seis decimales
    //     uint256 priceInWei = (fractionPrice * (10**6)) * amount;
    //     // Verifica que la cantidad de fracciones a invertir sea mayor a 0
    //     require(amount > 0, "Amount cannot be zero.");
    //     // Verifica que el contrato este en el estado de venta o "OnSale"
    //     require(contractStatus == Status.OnSale, "The sale is closed.");
    //     // Verifica que la cantidad de fracciones a comprar sea menor al total
    //     require(amount <= investmentFractions, "Amount to buy exceedes total fractions.");
    //     // Verifica que el suministro actual sumado a amount no supere el total
    //     require(totalSupply + amount <= investmentFractions, "Exceeding total fractions.");
    //     // Verifica que el balance del comprador sea suficiente para la compra
    //     require(usdt.balanceOf(msg.sender) >= priceInWei, 
    //         "Insufficient USDT balance.");
    //     // Verifica que el contrato tenga permiso de utilizar los fondos del comprador
    //     require(usdt.allowance(msg.sender, address(this)) >= priceInWei, 
    //         "In order to proceed, you must approve the required amount of USDT.");
    //     // Realiza la transferencia de los fondos hacia el contrato y verifica que la transaccion sea exitosa
    //     require(usdt.transferFrom(msg.sender, address(this), priceInWei), 
    //         "USDT transfer error.");

    //     // Mint en bloques
    //     _mintBatch(msg.sender, _ids, _amount,"");
    //     totalSupply += amount;

    //     // Se emite el evento
    //     emit Invest(msg.sender, amount);

    //     // Verifica si se han vendido todas las fracciones, en ese caso cambia el estado del contrato y emite el evento
    //     if (totalSupply == investmentFractions){
    //         contractStatus = Status.Sold;
    //         emit TotalAmountFinanced();
    //     }
    // }
    // Funcion que ejecutan los Admins para retirar los montos financiados

    function withdrawUSDT() public onlyRole(DEFAULT_ADMIN_ROLE) {
        // Calcula el balance en USDT del contrato
        uint256 contractBalance = usdt.balanceOf(address(this));
        // Verifica que el estado del contrato sea "Sold"
        require(contractStatus == Status.Sold, "Not on sold status.");
        // Transfiere los fondos del contrato hacia el admin y verifica que la transaccion sea exitosa
        require(usdt.transfer(msg.sender, contractBalance), "USDT transfer error.");
        // Cambia el estado de contrato a Milestones
        contractStatus = Status.Milestones;
        // Emite el evento
        emit WithdrawComplete();
    }

    // Funcion que ejecuta el Admin para ingresar el monto financiado mas el profit hacia el contrato
    // Ademas habilita el retiro de las ganancias para los inversores
    function setBuyBack(uint256 profit) public onlyRole(DEFAULT_ADMIN_ROLE) {
        // Verifica que el estado del contrato sea "Milestone"
        require(contractStatus == Status.Milestones, "Invalid status for Buyback.");
        // Verifica que el profit sea mayor a 0
        require(profit > 0, "Profit can't be zero");
        // Calcula el monto total a ingresar sumando el profit
        uint256 totalAmount = amountToFinance + ((amountToFinance * profit) / 100);
        totalAmount = totalAmount * (10**6);
        // Verifica que el balance del Admin sea suficiente
        require(totalAmount <= usdt.balanceOf(msg.sender), "Not enough USDT balance");
        // Verifica que el contrato tenga permiso para utilizar los fondos del Admin
        require(usdt.allowance(msg.sender, address(this)) >= totalAmount, 
            "In order to proceed, you must approve the required amount of USDT.");
        // Realiza la transferencia de los fondos hacia el contrato
        usdt.transferFrom(msg.sender, address(this), totalAmount);
        // Calcula el valor de las fracciones mas el profit
        buyBackPrice = fractionPrice + ((fractionPrice * profit) / 100);
        buyBackPrice = buyBackPrice * (10**6);
        // Cambia el estado del contrato a Finished
        contractStatus = Status.Finished;
    }


    // Funcion que ejecutan los inversores para retirar las ganancias

    function withdrawBuyBack() public {
        // Verifica que el estado del contrato sea "Finished"
        require(contractStatus == Status.Finished, "Contract is not finished.");

        uint256 nftsAmount = balanceOf(msg.sender, ID);
        // Verifica que este valor sea mayor a 0
        require(nftsAmount > 0, "Caller has not tokens.");
        // Calcula el monto total a retirar
        uint256 totalAmount = nftsAmount * buyBackPrice;
        // Se queman los NFTs en bloque
        _burn(msg.sender, ID, nftsAmount);
        // Se emite el evento
        emit BurnNfts(ID, nftsAmount);
        // Se realiza la transferencia del dinero a su wallet
        usdt.transfer(msg.sender, totalAmount);
    }


    // Funcion publica view para revisar el historial de compras realizadas

    function getHistorial() public view returns (HistoryFractions[] memory) {
        return historyFractions;
    }

        function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

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