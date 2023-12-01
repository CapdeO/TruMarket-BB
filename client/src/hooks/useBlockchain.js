import { BrowserProvider, JsonRpcProvider, Contract, ethers } from 'ethers'
import FactoryABI from '../abis/Factory.json'
import FinancingContract from '../abis/FinancingContract.json'
import USDTABI from '../abis/USDT.json'
import { useState } from 'react'

const FACTORY_CONTRACT = process.env.REACT_APP_FACTORY_CONTRACT_ADDRESS
const USDT_CONTRACT = process.env.REACT_APP_MUMBAI_USDT_ADDRESS

const useBlockchain = () => {
    const [address, setAddress] = useState('')

    const getNodeProvider = () => {
        return new JsonRpcProvider(import.meta.env.REACT_APP_MUMBAI_NODE)
    }

    const getFactoryContract = (provider) => {
        return new Contract(FACTORY_CONTRACT, FactoryABI.abi, provider)
    }

    const getFinancingContract = (provider, address) => {
        return new Contract(address, FinancingContract.abi, provider)
    }

    const getUSDTContract = (provider) => {
        return new Contract(USDT_CONTRACT, USDTABI.abi, provider)
    }

    const addMumbaiNetwork = async (provider) => {
        try {
            console.log({
                chainId: import.meta.env.REACT_APP_CHAIN_ID,
                chainName: import.meta.env.REACT_APP_NETWORK_NAME,
                rpcUrls: [import.meta.env.REACT_APP_NETWORK_URL],
                blockExplorerUrls: [import.meta.env.REACT_APP_BLOCK_EXPLORER_URL],
                nativeCurrency: {
                    name: import.meta.env.REACT_APP_CURRENCY_NAME,
                    symbol: import.meta.env.REACT_APP_CURRENCY_SYMBOL,
                    decimals: parseInt(import.meta.env.REACT_APP_CURRENCY_DECIMALS),
                },
            })
            await provider.request({
                method: 'wallet_addEthereumChain',
                params: [
                    {
                        chainId: import.meta.env.REACT_APP_CHAIN_ID,
                        chainName: import.meta.env.REACT_APP_NETWORK_NAME,
                        rpcUrls: [import.meta.env.REACT_APP_NETWORK_URL],
                        blockExplorerUrls: [import.meta.env.REACT_APP_BLOCK_EXPLORER_URL],
                        nativeCurrency: {
                            name: import.meta.env.REACT_APP_CURRENCY_NAME,
                            symbol: import.meta.env.REACT_APP_CURRENCY_SYMBOL,
                            decimals: parseInt(import.meta.env.REACT_APP_CURRENCY_DECIMALS),
                        },
                    },
                ],
            })
        } catch (err) {
            console.log(err)
        }
    }

    const getProvider = () => {
        let provider
        if (window.ethereum == null) {
            console.warn('MetaMask not installed; using read-only defaults')
            provider = ethers.getDefaultProvider()
        } else {
            provider = new BrowserProvider(window.ethereum)
        }

        return provider
    }

    const connectWallet = async () => {
        const provider = getProvider()
        const signer = await provider.getSigner()
        setAddress(signer.address)

        await addMumbaiNetwork(window.ethereum)
        await window.ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{ chainId: import.meta.env.CHAIN_ID }],
        })
    }

    // -------------------->  Contract functions

    const factoryFunc = async (name, amountToFinance, investmentFractions) => {
        const signer = await getProvider().getSigner()
        const contract = getFactoryContract(signer)
        return contract.FactoryFunc.send
            (
                name,
                amountToFinance,
                investmentFractions,
                USDT_CONTRACT
            )
    }

    const getUSDTBalance = async () => {
        const signer = await getProvider().getSigner()
        const contract = getUSDTContract(signer)
        var balance = await contract.balanceOf(signer.address)
    
        return balance
    }

    const getAllowance = async (_address) => {
        const signer = await getProvider().getSigner()
        const contract = getUSDTContract(signer)

        return contract.allowance(signer.address, _address)
    }

    const approbeFinancingContract = async (_address, _amountInWei) => {
        const signer = await getProvider().getSigner()
        const contract = getUSDTContract(signer);

        return contract.approve.send(_address, _amountInWei)
    }

    const invest = async (_address, _amount) => {
        const signer = await getProvider().getSigner()
        const contract = getFinancingContract(signer, _address);

        return contract.buyFraction(_amount)
    }

    const getAddresses = async () => {
        const signer = await getProvider().getSigner()
        const contract = getFactoryContract(signer)
        var addresses = await contract.getAddresses()

        return addresses
    }

    const getNFTsList = async () => {
        try {
            var list = await getAddresses()
            const signer = await getProvider().getSigner();
            const nftsInfo = await Promise.all(
                list.map(async (address) => {
                    const contract = getFinancingContract(signer, address);
                    const name = await contract.name();
                    const amountToFinance = await contract.amountToFinance();
                    const investmentFractions = await contract.investmentFractions();
                    const contractStatus = await contract.contractStatus();
                    const fractionPrice = await contract.fractionPrice()
                    var sold = await contract.totalSupply()

                    return {
                        address,
                        name,
                        amountToFinance,
                        investmentFractions,
                        contractStatus,
                        fractionPrice,
                        sold
                    };
                })
            );
            return nftsInfo;
        } catch (error) {
            console.error(error);
            throw error;
        }
    };

    return {
        connectWallet,
        getProvider,
        address,
        getUSDTBalance,
        factoryFunc,
        getAddresses,
        getNFTsList,
        getAllowance,
        approbeFinancingContract,
        invest
    }
}

export default useBlockchain