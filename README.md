----->>>> Tasks

Client:
- Dashboard de Admin con todos las colecciones de NFTs
- Enviar a dicho dashboard luego de efectuar la creacion de una colección
- Dashboard de Inversores 

Blockchain:
- Evaluar si mintear todos los NFT al contrato o dejar los minteos a cada inversor


Proyecto TruMarket

//Tru market es una empresa encargada de conectar mediante un red inversores

1- Factory

-Este es un contrato Upgradeable que su utilidad es crear contratos otros contratos ERC1155 mediante una función llamada FactoryFunc()

//Array
-Posee un array de address[] para guardar los contractos creados. address[] private addressesERC721Created. Este array va siendo rellenado en la funcion FactoryFunc() en la creación de cada nuevo contrato.

//Mappings
  mapping(address => uint256) public profits;
  mapping(address => uint256) public operationAmounts;

//Events
Utilizamos el siguiente event NewContractDeployed(address indexed deployedContract) y lo lanzamos en la creación de nuevo contrato en el metodo FactoryFunc()

//Functions

FactoryFunc()
-Dicha función recibe como parámetros(string memory _name,uint256 _amountToFinanceuint256 _investmentFractions,address _addUsdc) para la creacion del nuevo contrato.

getAddresses()
-Este método retorna el array de address de cada contrato.


//Interface

-Utiliza la interface un ERC20 en este caso USDT para utilizar sus métodos en los contratos. (transferFrom(), decimals(), allowance(), transfer(), approve(), balanceOf())

2- FinancingContract1155
-Es un contrato ERC1155. Con la capacidad de 

//Variables

-Posee variables fundamentales:
   uint256 amountToFinance- (Cantidad de dinero a financiar)
   uint256 investmentFractions- (Cantidad de fracciones)
   uint256 fractionPrice- (Precio de cada fracción)
   uint256 buyBackPrice- (Precio de recompra)
   bool withdraw- (Estado para retirar ganancias(true/false))
   USDT usdt- (Interface)

//Structs

-Posee un struct llamado HistoryFractions con los siguientes parámetros(
	uint256 fractions-(Cantidad de fracciones compradas)
        uint256 timestamp-(Tiempo exacto en el que se ejecutó la tx)
        address owner-(Dueño de las fracciones))
Los datos del struct cada vez que se ejectute la funcion buyFraction se van guardando en un array llamado HistoryFractions[] public historyFractions;

//Mappings

 mapping (uint256 => address) investors; 
 mapping (address => uint256) investorBalances;
 mapping (address => uint256[]) investorIds; (id de cada inversor guardado)
 mapping (address => uint256[]) investorAmounts; (cantidad de balance de cada inversor)

//Enums

Este contrato posee un enum para ver el estado en cada proceso de la empresa. Esta dividio en:
OnSale-Hace refencia que esta a la venta y puede ser comprado.
Sold-Hace referencia a que fue vendido.
Milestones-Hace referencia a los hitos, es decir los pasos.
Finished-Hace referencia a que el proceso completo fue finalizado.

//Events

event Invest(address investor, uint256 fractions);
event TotalAmountFinanced();
event WithdrawComplete();
event newMilestone(uint256 step, string description);
event BurnNft(uint256 tokenId);

//Contructor
En el contructor se encargada de recibir los parametros necesarios para la creación de fracciones.
Los más importantes son: amountToFinance, investmentFractions. Con estos valores podemos calcular el valor de cada fracción fractionPrice = amountToFinance / investmentFractions;
Ejemplo. amountToFinance = 10000, investmentFractions = 10, fractionPrice = 1000. El valor de cada fracción seria 1000usdc

//Functions
BuyFraction