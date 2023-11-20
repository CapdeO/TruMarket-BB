import React, { useState } from 'react';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import './Admin.scss'
import '../../utils/style/style.scss'
import BigButton from '../../components/BigButton/BigButton';
import ContractForm from '../../components/ContractForm/ContractForm';



const Admin = () => {

    const [contractForm, setContractForm] = useState(false);
    const [NFTsList, setNFTsList] = useState(false);

    const showContractForm = () => {
        setNFTsList(false);
        setContractForm(true);
    };

    const showNFTsList = () => {
        setContractForm(false);
        setNFTsList(true);
    };

    return (
        <div className='admin'>
            <Container className='margen'>
                <BigButton
                    text={'Approbe Contract'}
                    onClickButton={() => showContractForm()}
                    direction={'left'}
                />
                <BigButton
                    text={'Manage NFTs'}
                    onClickButton={() => showNFTsList()}
                    direction={'right'}
                />
            </Container>

            {contractForm && (
                <Container className={`margen`}>
                    <ContractForm />
                </Container>
            )}

            {NFTsList && (
                <Container className={`margen`}>
                    <h2>DIV2</h2>
                </Container>
            )}

        </div>
    )
}

export default Admin