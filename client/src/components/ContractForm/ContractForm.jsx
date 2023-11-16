import React from 'react'
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import './ContractForm.scss'

const ContractForm = () => {
    return <div className='contractForm'>

        <Form>
            <Form.Group className="mb-3" controlId="formName">
                <Form.Label>Contract Name</Form.Label>
                <Form.Control type="text" placeholder="Enter name" />
            </Form.Group>

            <Form.Group className="mb-3" controlId="formTotalAmount">
                <Form.Label>Total amount to finance</Form.Label>
                <Form.Control type="number" placeholder="Enter total amount" />
            </Form.Group>

            <Form.Group className="mb-3" controlId="formFractionsAmount">
                <Form.Label>NFTs amount</Form.Label>
                <Form.Control type="number" placeholder="Enter NFTs amount" />
            </Form.Group>

            <Form.Group className="mb-3" controlId="formFractionsPrice">
                <Form.Label>Price per NFT</Form.Label>
                <Form.Control type="number" readOnly  />
            </Form.Group>

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
}

export default ContractForm