import React, { useState, useEffect, useRef } from 'react';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import './Card.scss'
import Fade from 'react-reveal/Fade';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Alerta from '../../components/Alerta/Alerta'
import WaitingTransaction from '../WaitingTransaction/WaitingTransaction';
import useBlockchain from '../../hooks/useBlockchain'
import CardFruit from '../../assets/fruitsCard.jpg'

const Card = () => {

    return (
        <Fade left>
            <div className='card'>
                <h5 className='innerDiv'>
                    Contract Name
                </h5>
                <div className=''>
                    <img src={CardFruit} alt="fruits" className='cardFruit' />
                </div>
                <div className='innerDiv'>
                    <h6>Price:</h6>
                    <h6>$50</h6>
                </div>
                <div className='innerDiv'>
                    <h6>Sold:</h6>
                    <h6>12/150</h6>
                </div>
                
                <Row>
                    <Col>
                        
                    </Col>
                    <Col>
                    
                    </Col>
                </Row>



            </div>
        </Fade>

    )
}

export default Card