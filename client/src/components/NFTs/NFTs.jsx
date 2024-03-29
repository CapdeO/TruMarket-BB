import React, { useState, useEffect, useRef } from 'react';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import './NFTs.scss'
import Fade from 'react-reveal/Fade';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Alerta from '../../components/Alerta/Alerta'
import WaitingTransaction from '../WaitingTransaction/WaitingTransaction';
import useBlockchain from '../../hooks/useBlockchain'

const NFTs = () => {

    const { getNFTsList } = useBlockchain()
    const [nftsInfo, setNFTsInfo] = useState([])

    const getStatusLabel = (status) => {
        console.log(status)
        switch (status) {
            case 0:
                return "On Sale";
            case 1:
                return "Sold";
            case 2:
                return "Milestones";
            case 3:
                return "Finished";
            default:
                return "Unknown Status";
        }
    };

    const getCollections = async () => {
        try {
            const nftsInfo = await getNFTsList();
            console.error(nftsInfo);
            setNFTsInfo(nftsInfo);
        } catch (error) {
            console.error(error);
        }
    }

    const handleWithdraw = async (_address) => {
        console.log('Withdraw de: ', _address)
    }

    useEffect(() => {
        getCollections()
    }, []);

    return (
        <Fade left>
            <div className='nfts'>
                <Row>
                    <Col xs={1} className='centrado orange'>
                        #
                    </Col>
                    <Col xs={4} className='centrado orange'>
                        Name
                    </Col>
                    <Col className='centrado orange'>
                        OpAmount
                    </Col>
                    <Col className='centrado orange'>
                        Amount
                    </Col>
                    <Col className='centrado orange'>
                        Sold
                    </Col>
                    <Col className='centrado orange'>
                        Status
                    </Col>
                    <Col className='centrado'>
                        
                    </Col>
                </Row>

                {nftsInfo.map((nft, index) => (
                    <Fade right>
                    <Row key={index}>
                        <Col xs={1} className='centrado'>
                            {index + 1}
                        </Col>
                        <Col xs={4} className='centrado'>
                            {nft.name}
                        </Col>
                        <Col className='centrado'>
                            {Number(nft.operationAmount)}
                        </Col>
                        <Col className='centrado'>
                            {Number(nft.amountToFinance)}
                        </Col>
                        <Col className='centrado'>
                            {Number(nft.sold)} /{Number(nft.investmentFractions)} 
                        </Col>
                        <Col className='centrado'>
                            {getStatusLabel(Number(nft.contractStatus))}
                        </Col>
                        <Col className='centrado'>
                            {Number(nft.sold) === Number(nft.investmentFractions) && (
                                <Button variant="primary" onClick={() => handleWithdraw(nft.address)}>
                                    Withdraw
                                </Button>
                            )}
                        </Col>
                    </Row>
                    
                    </Fade>
                ))}
            </div>
        </Fade>
    );
}

export default NFTs