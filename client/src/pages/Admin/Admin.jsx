import React, { useState, useRef } from 'react';
import { Transition } from 'react-transition-group';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import './Admin.scss'
import '../../utils/style/style.scss'
import BigButton from '../../components/BigButton/BigButton';
import ContractForm from '../../components/ContractForm/ContractForm';



const Admin = () => {


    return <div className='admin'>
        <Container className='margen'>
            <BigButton
                text={'Approbe Contract'}
            //onClickButton={() => handleApproveContract()}
            />
            <BigButton
                text={'Manage NFTs'}
            //onClickButton={() => handleManageNFTs()}
            />
        </Container>

        https://www.youtube.com/watch?v=3_wFkcg7gTI&ab_channel=GaurAssociates

        <Container className='margen' >
            <ContractForm />
        </Container>





    </div>
}


export default Admin