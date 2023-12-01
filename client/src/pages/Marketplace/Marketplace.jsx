import React, { useState, useEffect } from 'react';
import './Marketplace.scss'
import Card from '../../components/Card/Card'
import Card2 from '../../components/Card2/Card2'
import useBlockchain from '../../hooks/useBlockchain';

const Marketplace = () => {
    const { getNFTsList } = useBlockchain();
    const [availableNFTs, setAvailableNFTs] = useState([]);

    useEffect(() => {
        const fetchAvailableNFTs = async () => {
            try {
                const nfts = await getNFTsList();
                const availableNFTs = nfts.filter(nft => Number(nft.sold) < Number(nft.investmentFractions));
                setAvailableNFTs(availableNFTs);
            } catch (error) {
                console.error(error);
                setAvailableNFTs([]);
            }
        };

        fetchAvailableNFTs();
    }, []);


    return (
        <div className='marketplace'>
            {availableNFTs.map((nft, index) => {
                return (
                    <Card2 key={index} add={nft.address} name={nft.name} price={Number(nft.fractionPrice)} investedFractions={nft.investedFractions} sold={`${nft.sold}/${nft.investmentFractions}`} />
                );
            })}
        </div>
    );
}

export default Marketplace