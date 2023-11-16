import React, { useState, useRef, useEffect } from 'react';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import './Admin.scss'
import '../../utils/style/style.scss'
import BigButton from '../../components/BigButton/BigButton';
import ContractForm from '../../components/ContractForm/ContractForm';

const Admin = () => {


    const [formHeight, setFormHeight] = useState(0);
    const [manageNFTsHeight, setManageNFTsHeight] = useState(0);
    const [showForm, setShowForm] = useState(false);
    const [showManageNFTs, setShowManageNFTs] = useState(false);

    const formRef = useRef(null);
    const manageRef = useRef(null);

    const handleApproveContract = () => {
        setShowManageNFTs(false);
        setShowForm(true);
        setManageNFTsHeight(0);
        setFormHeight((prev) => (prev === 0 ? formRef.current.scrollHeight : 0));
      };
    
      const handleManageNFTs = () => {
        setShowForm(false);
        setShowManageNFTs(true);
        setFormHeight(0);
        setManageNFTsHeight((prev) => (prev === 0 ? manageRef.current.scrollHeight : 0));
      };


    //const formRef = useRef(null);
    //const manageRef = useRef(null);

    return <div className='admin'>
        <Container className='margen'>
            <BigButton
                text={'Approbe Contract'}
                onClickButton={() => handleApproveContract()}
            />
            <BigButton
                text={'Manage NFTs'}
                onClickButton={() => handleManageNFTs()}
            />
        </Container>

        {showForm && (
            <Container className='margen' style={{ height: formHeight }}>
                <ContractForm ref={formRef} />
            </Container>
        )}

        {showManageNFTs && (
            <Container className='margen' style={{ height: manageNFTsHeight }}>
                <h4 ref={manageRef}>HOLA</h4>
            </Container>
        )}



    </div>
}

export default Admin