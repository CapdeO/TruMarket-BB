----->>>> Tasks

Client:
- Dashboard de Admin con todos las colecciones de NFTs
- Enviar a dicho dashboard luego de efectuar la creacion de una colección
- Dashboard de Inversores 

Blockchain:
- Evaluar si mintear todos los NFT al contrato o dejar los minteos a cada inversor


# TruMarket Project

Tru Market is a blockchain-based platform that connects local producers with global buyers, ensuring transparency and trust in the value chain from farm to table.

## Mission

TruMarket's mission is to enable complete traceability in global supply chains using blockchain and smart contracts. This provides customers with a transparent view of product origin, journey, and quality while creating opportunities for sustainable practices among suppliers.

### Smart Contracts

Smart contracts secure agreements between parties in a tamper-proof manner, executing terms encoded in a blockchain network, including payments.

### Operations and Quality Control

Every operation undergoes real-time inspection, with quality control shared among stakeholders and accessible from any device.

### Consumer Access

Consumers can access public data by scanning smart labels to understand a product's history.

## Factory Contract

The Factory contract is Upgradeable and creates ERC1155 contracts using the FactoryFunc() function.

### Key Functions

- `FactoryFunc()`: Creates contracts with specific parameters and stores relevant information.
- `getAddresses()`: Returns an array with addresses of each contract.

## FinancingContract1155

This contract is ERC1155 and offers several features and functions.

### Key Variables

- `amountToFinance`
- `investmentFractions`
- `fractionPrice`
- `buyBackPrice`
- `withdraw`
- `USDT usdt`

### Key Functions

- `BuyFraction(uint256 _amount)`: Enables purchase of fractions with rigorous checks.
- `setBuyBack(uint256 profit)`: Sets profits and changes contract state.
- `withdrawBuyBack()`: Allows profit withdrawal and burning of NFT tokens.
- `withdrawUSDT()`: Admin method to withdraw USDT.

### Structures and Mappings

- `HistoryFractions`: Custom record of purchased fractions.
- Mappings for balances, investor IDs, amounts, and states.

### Events

- `Invest`
- `TotalAmountFinanced`
- `WithdrawComplete`
- `BurnNfts`

### Additional Function

- `getHistorial()`: Returns the history of fractions.


# DIAGRAM

![Alt text](image.png)

### Sequence Diagram: TruMarket Transaction Flow

```@startuml

skinparam participant {
    BackgroundColor DarkSeaGreen
    BorderColor DarkSlateGray
}

skinparam note {
    BackgroundColor LightYellow
    BorderColor DarkSlateGray
}

participant Buyer
participant "TruMarket" as TruMarket
participant Investors
participant Suppliers

autonumber

== Order ==

Buyer -> TruMarket: Places order
TruMarket -> TruMarket: Creates contract and NFTs
note right: Generates contract\nand NFTs

== Financing ==

TruMarket --> Investors: Offers NFTs
Investors -> TruMarket: Purchase NFTs
note left: Investors\npurchase NFTs

== Transaction and Delivery ==

alt Financing Completed
    TruMarket -> TruMarket: Converts crypto to FIAT
    note right: Converts\ncrypto to FIAT
    TruMarket -> Suppliers: Pays with FIAT
    note right: Pays to\nsuppliers
    Suppliers -> Suppliers: Prepares and ships merchandise
    note right: Prepares and\nships merchandise
    Suppliers --> Buyer: Sends merchandise
    note left: Sends merchandise\nto buyer
    Buyer --> TruMarket: Pays total amount
    note right: Pays total amount
    TruMarket -> TruMarket: Converts FIAT to crypto
    note right: Converts\nFIAT to crypto
    TruMarket -> Investors: Pays profits by repurchasing NFTs
    note left: Pays profits\nto investors
else Financing Not Completed
    TruMarket -> TruMarket: Cancels transaction
    note right: Cancels\ntransaction
end

@enduml

``` 



