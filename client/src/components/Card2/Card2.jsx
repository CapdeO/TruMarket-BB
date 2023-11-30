import Card from 'react-bootstrap/Card';
import CardFruit from '../../assets/fruitsCard.jpg'
import Button from 'react-bootstrap/Button';
import Fade from 'react-reveal/Fade';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Form from 'react-bootstrap/Form';
import './Card2.scss'

function Card2() {
    return (
        <Fade left>
            <Card style={{ width: '18rem' }}>
                <Card.Img variant="top" src={CardFruit} />
                <Card.Body>
                    <Card.Title>Card Title</Card.Title>
                    <Row className='innedCard'>
                        <Col>Price:</Col>
                        <Col>$50</Col>
                    </Row>
                    <Row className='innedCard'>
                        <Col>Sold:</Col>
                        <Col>102/150</Col>
                    </Row>
                    <Row className='innedCard'>
                        <Col>Profit:</Col>
                        <Col>%15</Col>
                    </Row>
                    <Row className='centrado'>
                        <Col xs={5}>
                            <Form.Control
                                type="number"
                                id="exampleColorInput"
                                defaultValue="#563d7c"
                                title="Choose your color"
                            />
                        </Col>
                        <Col xs={5}>
                            <Button variant="primary">Invest</Button>
                        </Col>
                    </Row>
                </Card.Body>
            </Card>
        </Fade>
    );
}

export default Card2;