"use client"

import { 
  ConnectWallet, 
  ThirdwebProvider, 
  coinbaseWallet, 
  embeddedWallet, 
  metamaskWallet, 
  smartWallet, 
  useAddAdmin, 
  useAddress, 
  useContract, 
  useContractRead, 
  useContractWrite,
  walletConnect 
} from "@thirdweb-dev/react"

import './page.scss'
import { FACTORY_ADDRESS } from "../../constants/addresses"

export default function Home() {

  const smartWalletConfig = {
    factoryAddress: '0x25977D04c936D8855040738fCF4C874709Da997a',
    gasless: true,
  }

  const truMarketWallet = smartWallet(embeddedWallet({recommended: true}), smartWalletConfig)
  truMarketWallet.meta.name = 'TruMarket Wallet'
  truMarketWallet.meta.iconURL = 'https://media.licdn.com/dms/image/C4D0BAQEItW2QBcZgJg/company-logo_200_200/0/1656376345338?e=2147483647&v=beta&t=JJ5zqv4QaE0CdCTej1-eJ1aw4-i4EE8-Ltqzwfc0pEg'

  return (
    <ThirdwebProvider
      activeChain='mumbai'
      clientId='dee865d2383b0f7bbfccb08ec7781f78'
      supportedWallets={[
        truMarketWallet,
        metamaskWallet(),
        coinbaseWallet(),
        walletConnect()
      ]}
    >
      <App />
    </ThirdwebProvider>
  )
}

function App() {
  const address = useAddress()
  const factoryAdd = FACTORY_ADDRESS

  const {
    contract: factoryContract
  } = useContract(factoryAdd)

  const { data, isLoading, error } = useContractRead(factoryContract, "getAddresses")

  return (
    <div className="app">
      <ConnectWallet />

      {address ? (
        <>
          {console.log('Conectado con la billetera:', address)}
          {/* {console.log('Factory address:', factoryContract.getAddress())} */}
          {console.log('Addresses:', data)}
        </>
      ) : (
        <>
          {console.log('No está conectado')}
        </>
      )}
    </div>
    
  )
}