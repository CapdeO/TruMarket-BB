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
            setNFTsInfo(nftsInfo);
        } catch (error) {
            console.error(error);
        }
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
                    <Col xs={5} className='centrado orange'>
                        Name
                    </Col>
                    <Col className='centrado orange'>
                        Amount
                    </Col>
                    <Col xs={1} className='centrado orange'>
                        NFTs
                    </Col>
                    <Col className='centrado orange'>
                        Status
                    </Col>
                </Row>

                {nftsInfo.map((nft, index) => (
                    <Fade right>
                    <Row key={index}>
                        <Col xs={1} className='centrado'>
                            {index + 1}
                        </Col>
                        <Col xs={5} className='centrado'>
                            {nft.name}
                        </Col>
                        <Col className='centrado'>
                            {Number(nft.amountToFinance)}
                        </Col>
                        <Col xs={1} className='centrado'>
                            {Number(nft.investmentFractions)} 
                        </Col>
                        <Col className='centrado'>
                            {getStatusLabel(Number(nft.contractStatus))}
                        </Col>
                    </Row>
                    </Fade>
                ))}
            </div>
        </Fade>
    );
}

export default NFTs