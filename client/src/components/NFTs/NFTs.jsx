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

    const {
        getAddresses
    } = useBlockchain()

    // const getCollections = async () => {
    //     await getAddresses()
    //         .then(async (tx) => {
    //             await tx.wait()
    //             console.log(tx.response)
    //         })
    //         .catch((error) => {
    //             console.error(error)
    //         })
    // }

    const getCollections = async () => {
        try {
            const tx = await getAddresses();
            console.log(tx.response);
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
                NFTs
            </div>
        </Fade>

    )
}

export default NFTs