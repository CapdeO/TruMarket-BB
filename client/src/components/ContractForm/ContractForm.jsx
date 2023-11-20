import React, { useState, useEffect } from 'react';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import './ContractForm.scss'
import Fade from 'react-reveal/Fade';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Alerta from '../../components/Alerta/Alerta'

const ContractForm = () => {

    const [totalAmount, setTotalAmount] = useState('');
    const [NFTsAmount, setNFTsAmount] = useState('');
    const [NFTPrice, setNFTPrice] = useState(0);
    const [milestones, setMilestones] = useState(3);

    // MILESTONE ------------------------------------------------------------------

    const [milestoneData, setMilestoneData] = useState(Array.from({ length: 3 }, (_, index) => ({ id: index + 1, name: '', percentage: '' })));

    const handleMilestonesChange = (e) => {
        const newMilestones = parseInt(e.target.value, 10);
        setMilestones(newMilestones);

        setMilestoneData((prevData) => {
            const newData = [];
            for (let i = 1; i <= newMilestones; i++) {
                const existingMilestone = prevData.find((milestone) => milestone.id === i);
                newData.push(existingMilestone || { id: i, name: '', percentage: '' });
            }
            return newData;
        });
    };

    const handleMilestoneInputChange = (id, field, value) => {
        setMilestoneData((prevData) =>
            prevData.map((milestone) =>
                milestone.id === id ? { ...milestone, [field]: value } : milestone
            )
        );
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        // Validación de nombres y porcentajes
        const hasEmptyNames = milestoneData.some((milestone) => milestone.name.trim() === '');
        const totalPercentage = milestoneData.reduce((sum, milestone) => sum + parseFloat(milestone.percentage) || 0, 0);

        if (hasEmptyNames) {
            Alerta({
                title: 'Error',
                text: `Por favor, completa todos los nombres de los hitos.`,
                img: Error,
            })
        } else if (totalPercentage != 100) {
            Alerta({
                title: 'Error',
                text: `La suma de los porcentajes debe ser igual a 100%.`,
                img: Error,
            })
        } else {
            // Puedes realizar la acción de submit aquí
            console.log('Milestone Data:', milestoneData);
        }
    };

    // MILESTONE ------------------------------------------------------------------

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
        <Fade left>
            <div className='contractForm'>

                <Form onSubmit={handleSubmit}>
                    <Form.Group className="mb-3" controlId="formName">
                        <Form.Label>Contract Name</Form.Label>
                        <Form.Control type="text" placeholder="Enter name" required />
                    </Form.Group>

                    <Form.Group className="mb-3" controlId="formTotalAmount">
                        <Form.Label>Total amount to finance</Form.Label>
                        <Form.Control type="number" placeholder="Enter total amount" value={totalAmount} onChange={handleTotalAmountChange} required />
                    </Form.Group>

                    <Row>
                        <Col>
                            <Form.Group className="mb-3" controlId="formFractionsAmount">
                                <Form.Label>NFTs amount</Form.Label>
                                <Form.Control type="number" placeholder="Enter NFTs amount" value={NFTsAmount} onChange={handleNFTsAmountChange} required />
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
                                <Form.Range min={3} max={9} value={milestones} onChange={handleMilestonesChange} />
                            </Form.Group>
                        </Col>
                        <Col className='centrado'>
                            <h5>{milestones}</h5>
                        </Col>
                    </Row>

                    <Row>
                        <Col xs={1}>
                            <Form.Label>#</Form.Label>
                        </Col>
                        <Col>
                            <Form.Label>Milestone Name</Form.Label>
                        </Col>
                        <Col xs={2}>
                            <Form.Label>%</Form.Label>
                        </Col>
                    </Row>


                    {/* <Row>
                        <Col xs={1} className='centrado'>
                            <Form.Label>1</Form.Label>
                        </Col>
                        <Col>
                            <Form.Group className="mb-3" controlId="formName">
                                <Form.Control type="text" placeholder="Enter name" />
                            </Form.Group>
                        </Col>
                        <Col xs={3}>
                            <Form.Group className="mb-3" controlId="formName">
                                <Form.Control type="text" placeholder="Enter name" />
                            </Form.Group>
                        </Col>
                    </Row> */}

                    {milestoneData.map((milestone) => (

                        <Form.Group key={milestone.id} controlId={`milestone-${milestone.id}`}>
                            <Fade left >
                                <Row>
                                    <Col xs={1} className='centrado'>
                                        <Form.Label>{`${milestone.id}`}</Form.Label>
                                    </Col>
                                    <Col>
                                        <Form.Control
                                            type="text"
                                            placeholder={`Milestone #${milestone.id}`}
                                            value={milestone.name}
                                            onChange={(e) => handleMilestoneInputChange(milestone.id, 'name', e.target.value)}
                                        />
                                    </Col>
                                    <Col xs={3}>
                                        <Form.Control
                                            type="number"
                                            placeholder="%"
                                            value={milestone.percentage}
                                            onChange={(e) =>
                                                handleMilestoneInputChange(milestone.id, 'percentage', e.target.value)
                                            }
                                        />
                                    </Col>
                                </Row>
                            </Fade>
                        </Form.Group>
                    ))}


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
        </Fade>

    )
}

export default ContractForm