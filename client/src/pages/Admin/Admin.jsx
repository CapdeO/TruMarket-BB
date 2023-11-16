import React, { useState, useRef  } from 'react';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import './Admin.scss'
import '../../utils/style/style.scss'
import BigButton from '../../components/BigButton/BigButton';
import ContractForm from '../../components/ContractForm/ContractForm';

const Admin = () => {

    const [showForm, setShowForm] = useState(false);
    const formRef = useRef(null);

    const handleApproveContract = () => {
        setShowForm(true);

        if (formRef.current) {
            formRef.current.scrollIntoView({
                behavior: 'smooth',
                block: 'start',
            });
        }
    };

    return <div className='admin'>
        <Container className='margen'>
            <BigButton
                text={'Approbe Contract'}
                onClickButton={() => handleApproveContract()}
            />
            <BigButton
                text={'Manage NFTs'}
            //onClickButton={() => showAlert()}
            />
        </Container>

        {showForm && (
            <Container className='margen'>
                <ContractForm  ref={formRef} />
            </Container>
        )}



    </div>
}

export default Admin