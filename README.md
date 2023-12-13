----->>>> Tasks

Client:
- Dashboard de Admin con todos las colecciones de NFTs
- Enviar a dicho dashboard luego de efectuar la creacion de una colección
- Dashboard de Inversores 

Blockchain:
- Evaluar si mintear todos los NFT al contrato o dejar los minteos a cada inversor


Proyecto TruMarket

//Tru market es una empresa que tiene como mision ayudar a los productores locales a conectarse con compradores globales, a través de una plataforma basada en blockchain que garantiza la transparencia y la confianza en la cadena de valor desde la granja hasta la mesa.

Nuestra misión es permitir la trazabilidad de extremo a extremo en las cadenas de suministro globales utilizando blockchain y contratos inteligentes, brindando a los clientes una visión transparente del origen, el recorrido y la calidad de los productos que compran, mientras creamos oportunidades para que los proveedores se diferencien a través de prácticas sostenibles y éticas.

Los contratos inteligentes aumentan la confianza al proporcionar una forma segura y a prueba de manipulaciones para ejecutar acuerdos entre las partes. Una vez que se definen y acuerdan los términos del contrato, se codifican en una red blockchain, lo que permite la ejecución automatizada de los términos del contrato. Todos los pagos se guardan y aseguran en una cuenta de depósito en garantía y se liberan de acuerdo con su acuerdo digital cuando se completan y verifican los hitos. Como resultado, los contratos inteligentes tienen el potencial de aumentar en gran medida la eficiencia y seguridad de una amplia gama de operaciones.

Cada operación pasa por una inspección in situ. El seguimiento de todos los procesos y el control de calidad del producto se produce en tiempo real y es compartido entre todos los actores y accesible a través de cualquier dispositivo.

Además, el consumidor final puede consultar todos los datos públicos escaneando la etiqueta inteligente colocada en el envase y conocer la verdadera historia detrás del producto que está adquiriendo.

1- Factory

-Este es un contrato Upgradeable que su utilidad es crear contratos otros contratos ERC1155 mediante una función llamada FactoryFunc()

//Array
-Posee un array de address[] para guardar los contractos creados. address[] private addressesERC721Created. Este array va siendo rellenado en la funcion FactoryFunc() en la creación de cada nuevo contrato.

//Mappings
Posee un mapping que relaciona el address del contrato con el monto de la operacion llamado operationAmounts

//Events
Utilizamos el siguiente event NewContractDeployed(address indexed deployedContract) y lo lanzamos en la creación de nuevo contrato en el metodo FactoryFunc(). Notitifica que se creo un nuevo contrato.

//Functions

FactoryFunc()
-Dicha función recibe como parámetros(string memory _name,uint256 _amountToFinanceuint256 _investmentFractions,address _addUsdc) para la creacion del nuevo contrato. Almacena el monto de la operación en el mapping. Agrega al array de address el nuevo contrato. Lanza el evento para notificar la creación del nuevo contrato.

getAddresses()
-Este método retorna el array de address de cada contrato.


//Interface

-Utiliza la interface un ERC20 en este caso USDT para utilizar sus métodos en los contratos. (transferFrom(), decimals(), allowance(), transfer(), approve(), balanceOf())

2- FinancingContract1155
-Es un contrato ERC1155. Con la capacidad de...

//Variables

-Posee variables fundamentales:
   uint256 amountToFinance- (Cantidad de dinero a financiar)
   uint256 investmentFractions- (Cantidad de fracciones)
   uint256 fractionPrice- (Precio de cada fracción)
   uint256 buyBackPrice- (Precio de recompra)
   bool withdraw- (Estado para retirar ganancias(true/false))
   USDT usdt- (Interface)

//Structs

-Posee un struct llamado HistoryFractions con 3 importantes parametros para dejar un registro personalizado. fractions-(Cantidad de fracciones compradas), timestamp-(Tiempo exacto en el que se ejecutó la tx), owner-(Dueño de las fracciones).
Los datos del struct cada vez que se ejectute la funcion buyFraction se van guardando en un array llamado historyFractions;

//Mappings

Este contrato posee 3 importantes mappings. investorBalances almacena la cantidad de nft de cada inversor. investorIds almacena un array con los ids de cada inversor. investorAmounts almacena en un array la cantidad de id que tiene cada inversor

//Enums

Este contrato posee un enum para ver el estado en cada proceso de la empresa. Esta dividio en:
OnSale-Hace refencia que esta a la venta y puede ser comprado.
Sold-Hace referencia a que fue vendido.
Milestones-Hace referencia a los hitos, es decir los pasos.
Finished-Hace referencia a que el proceso completo fue finalizado.

//Events

Posee eventos para cada momento del proceso de la empresa.
El primer evento llamado Invest notifica la compra realizada con el address del inversor y la cantidad de fracciones.
El segundo evento llamado TotalAmountFinanced notifica cuando se alcanza el monto total financiado.
El tercer evento llamado WithdrawComplete notifica cuando se ha completado el proceso de retirada de ganancias.
El último evento llamado BurnNfts notifica cuando se ha borrado un nft y los ids de ciertos nfts.

//Contructor
En el contructor se encargada de recibir los parametros necesarios para la creación de fracciones.
Los más importantes son: amountToFinance, investmentFractions. Con estos valores podemos calcular el valor de cada fracción fractionPrice = amountToFinance / investmentFractions;
Ejemplo. amountToFinance = 10000, investmentFractions = 10, fractionPrice = 1000. El valor de cada fracción seria 1000usdc

//Functions
BuyFraction(uint256 _amount)
-Esta función publica recibe como parámetro un número entero que representa la cantidad de fracciones a comprar/invertir.
El método utiliza ciertas verificaciones a través de requires. 
Verifica que el estado sea OnSale para que este permitido la compra.
Verifica que el valor del _amount no sea 0 ya que no es posible.
Verifica que el balance en usdt del comprador sea suficiente en relacion al precio requerido.
Verifica que el contrato tiene permiso de usar los fondos del comprador..
Y por último una vez pasadas las verificaciones realiza la transferencia.


Luego crea una array _ids para almacenar los tokens que se van a crear y un array _amounts para almacenar las cantidades de tokens que se van a crear.
En el bucle for, se crea un token NFT para cada iteración. Se utiliza la variable _nextTokenId para asignar un ID único a cada token. El token se asigna al inversor (el usuario que llama a la función) y se incrementa _nextTokenId para el próximo token.
también se crea un arreglo _amounts para almacenar las cantidades de tokens que se van a crear. Como se quiere crear un token por iteración, se asigna el valor 1 a cada posición del array.
Luego, se utiliza la función _mintBatch para crear los tokens NFT en bloques. Esta función acepta el inversor (el usuario que llama a la función), los ID de los tokens, las cantidades de tokens y un mensaje.

Finalmente, se actualiza el saldo del inversor en el diccionario investorBalances.

Al completrase se emite el evento Invest que envia el comprador y la cantidad de fracciones compradas.

Se llenan los datos del struct historyFractions con los valores indicados.

Cambia al estado Sold.

setBuyBack(uint256 profit)
Este metodo es ejectudo por el admin unicamente y lo que hace es utilizar un porcentaje aproximado para calcular las ganancias.

Verifica que el profit sea mayor a 0

calcula en una varible totalAmount. Utilizando el valor invertido y sumando un porcentaje de ganancia pasado por el admin.

Verifica que el balance del admin sea sufiente para pagar las ganancias.
Verifica que el contrato tenga permisos de utilizar los fondos del admin. 

Calcula el monto de cada fracción mas el profit.

Ejecuta la tranferencia.

Cambia al estado Finished.

witdrawBuyBack()

Verifica que el estado sea Finished
Verifica que que las longuitudes de los array de ids sea igual a la de amounts.
Verifica que la longuitud del array de los ids sea igual balance.
Si pasan las verificaciones anteriores se calcula la cantidad de nft a quemar que tambien verifica que sea mayor a 0.

se ejecuta _burnBatch
La quema de tokens NFT implica la eliminación de estos tokens de la cadena de bloques y el envío de la cantidad equivalente de USDT (Tether) al inversor.
Esta función acepta el inversor (el usuario que llama a la función), los ID de los tokens que se van a quemar, las cantidades de tokens que se van a quemar y un mensaje.
Después, se emite el evento BurnNfts para notificar a los usuarios que los tokens NFT han sido quemados.
Luego, se eliminan las entradas del inversor en los diccionarios investorIds, investorAmounts e investorBalances.
Finalmente, se utiliza la función transfer del contrato USDT para enviar la cantidad total de USDT (Tether) al inversor.

withdrawUSDT()
Este metodo ejectuda por el admin

Calcula el balance de usdt en el contrato
Verifica que el estado sea Sold
Hace la tranferencia para retirar los usdt
El estado pasa a Milestones
Se emite el evento WithdrawComplete() para notiticar que se retiro el balance.

getHistorial()
Esta funcion retorna el array con el historial de fracciones.