import React, { useState, useEffect  } from 'react';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import './ContractForm.scss'
import Flip from 'react-reveal/Flip';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';

const ContractForm = () => {

    const [totalAmount, setTotalAmount] = useState('');
    const [NFTsAmount, setNFTsAmount] = useState('');
    const [NFTPrice, setNFTPrice] = useState(0);
    const [milestones, setMilestones] = useState(5);

    useEffect(() => {
        updateNFTPrice();
    }, [totalAmount, NFTsAmount]);

    const updateNFTPrice = () => {
        if (totalAmount != '' && NFTsAmount != '') {
            const totalAmountValue = parseFloat(totalAmount);
            const NFTsAmountValue = parseFloat(NFTsAmount);
            const pricePerNFT = totalAmountValue / NFTsAmountValue;
            setNFTPrice(pricePerNFT);
        } else {
            setNFTPrice('');
        }
    };
    

    const handleTotalAmountChange = (event) => {
        if (event.target.value > 0 || event.target.value == '')
            setTotalAmount(event.target.value);
    };

    const handleNFTsAmountChange = event => {
        if (event.target.value > 0 || event.target.value == '')
            setNFTsAmount(event.target.value);
    };
    

    return (
        <Flip left>
            <div className='contractForm'>

                <Form>
                    <Form.Group className="mb-3" controlId="formName">
                        <Form.Label>Contract Name</Form.Label>
                        <Form.Control type="text" placeholder="Enter name" />
                    </Form.Group>

                    <Form.Group className="mb-3" controlId="formTotalAmount">
                        <Form.Label>Total amount to finance</Form.Label>
                        <Form.Control type="number" placeholder="Enter total amount" value={totalAmount} onChange={handleTotalAmountChange} />
                    </Form.Group>

                    <Row>
                        <Col>
                            <Form.Group className="mb-3" controlId="formFractionsAmount">
                                <Form.Label>NFTs amount</Form.Label>
                                <Form.Control type="number" placeholder="Enter NFTs amount" value={NFTsAmount} onChange={handleNFTsAmountChange} />
                            </Form.Group>
                        </Col>
                        <Col>
                            <Form.Group className="mb-3" controlId="formFractionsPrice">
                                <Form.Label>Price per NFT</Form.Label>
                                <Form.Control value={NFTPrice} type="number" readOnly />
                            </Form.Group>
                        </Col>
                    </Row>


                    <Row>
                        <Col xs={8}>
                            <Form.Group className="mb-3" controlId="formMilestonesAmount">
                                <Form.Label>Milestones</Form.Label>
                                <Form.Range min={3} max={9} value={milestones} onChange={(e) => setMilestones(e.target.value)} />
                            </Form.Group>
                        </Col>
                        <Col>
                            <h3>{milestones}</h3>
                        </Col>
                    </Row>




                    <Row>
                        <Col>
                            <Form.Group className="mb-3" controlId="formName">
                                <Form.Label>Contract Name</Form.Label>
                                <Form.Control type="text" placeholder="Enter name" />
                            </Form.Group>
                        </Col>
                        <Col>
                            <Form.Group className="mb-3" controlId="formName">
                                <Form.Label>Contract Name</Form.Label>
                                <Form.Control type="text" placeholder="Enter name" />
                            </Form.Group>
                        </Col>
                        <Col>
                            <Form.Group className="mb-3" controlId="formName">
                                <Form.Label>Contract Name</Form.Label>
                                <Form.Control type="text" placeholder="Enter name" />
                            </Form.Group>
                        </Col>
                    </Row>



                    {/* <Form.Group className="mb-3" controlId="formBasicPassword">
                        <Form.Label>Password</Form.Label>
                        <Form.Control type="password" placeholder="Password" />
                    </Form.Group>
                    <Form.Group className="mb-3" controlId="formBasicCheckbox">
                        <Form.Check type="checkbox" label="Check me out" />
                    </Form.Group> */}

                    <Button variant="primary" type="submit">
                        Create Smart Contract
                    </Button>
                </Form>
            </div>
        </Flip>

    )
}

export default ContractForm