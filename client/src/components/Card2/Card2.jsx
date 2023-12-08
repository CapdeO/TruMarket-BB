import React, { useState, useEffect, useRef } from 'react';
import Card from 'react-bootstrap/Card';
import CardFruit from '../../assets/fruitsCard.jpg'
import Button from 'react-bootstrap/Button';
import Fade from 'react-reveal/Fade';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Form from 'react-bootstrap/Form';
import './Card2.scss'
import useBlockchain from '../../hooks/useBlockchain';
import Alerta from '../Alerta/Alerta';
import WaitingTransaction from '../WaitingTransaction/WaitingTransaction'

function Card2({ add, name, price, investedFractions, sold }) {
    const { invest, getUSDTBalance, getAllowance, approbeFinancingContract } = useBlockchain()
    const [tokenAmount, setTokenAmount] = React.useState('')

    console.log(sold)
    console.log(investedFractions)

    const prepareBuy = async () => {
        let USDTPrice = tokenAmount * price
        let USDTPriceInWei = USDTPrice * 10 ** 6
        let balance = await getUSDTBalance()

        if (balance < USDTPriceInWei) {
            Alerta({
                title: 'Insufficient USDT balance.',
                text: `You need at least ${USDTPrice} USDT in your wallet.`,
                img: Error,
            })
        } else {
            let allowance = await getAllowance(add)
            if (allowance < USDTPriceInWei) {
                WaitingTransaction({
                    title: 'USDT approval',
                    text: 'Processing transaction. Please wait',
                    active: true,
                })
                approbeFinancingContract(add, USDTPriceInWei)
                    .then(async (tx) => {
                        await tx.wait()
                        WaitingTransaction({ active: false })
                        buy()
                    })
                    .catch((error) => {
                        console.error(error)
                        Alerta({
                            title: 'Error',
                            text: 'Approve error',
                            img: Error,
                        })
                    })
            } else {
                buy()
            }
        }
    }

    const buy = async () => {
        WaitingTransaction({
            title: 'NFTs Purchase',
            text: 'Processing purchase. Please wait',
            active: true,
        })
        invest(add, tokenAmount)
            .then(async (tx) => {
                await tx.wait()
                WaitingTransaction({ active: false })
                Alerta({
                    title: 'Purchase completed',
                    text: `You have successfully purchased ${tokenAmount} NFT(s)`,
                    img: 'success',
                })
            })
            .catch((error) => {
                console.error(error)
                Alerta({
                    title: 'Error',
                    text: error.message,
                    img: Error,
                })
            })
    }

    const handleTokenAmountChange = (event) => {
        setTokenAmount(event.target.value)
    }

    return (
        <Fade left>
            <Card style={{ width: '18rem' }}>
                <Card.Img variant="top" src={CardFruit} />
                <Card.Body>
                    <Card.Title>{name}</Card.Title>
                    <Row className='innedCard'>
                        <Col>Price:</Col>
                        <Col>${price}</Col>
                    </Row>
                    <Row className='innedCard'>
                        <Col>Sold:</Col>
                        <Col>{sold}/{investedFractions}</Col>
                    </Row>
                    <Row className='innedCard'>
                        <Col>Profit:</Col>
                        <Col>%6</Col>
                    </Row>
                    <Row className='centrado' style={{ marginTop: '15px' }}>
                        <Col xs={5}>
                            <Form.Control
                                type="number"
                                value={tokenAmount}
                                onChange={handleTokenAmountChange}
                            />
                        </Col>
                        <Col xs={5}>
                            <Button variant="primary" onClick={() => prepareBuy()}>Invest</Button>
                        </Col>
                    </Row>
                </Card.Body>
            </Card>
        </Fade>
    );
}

export default Card2;