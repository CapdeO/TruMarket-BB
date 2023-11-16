import React from 'react'
import './BigButton.scss'
import logo from '../../assets/logo.png'

const BigButton = ({ text, onClickButton }) => {
    return <button className='bigButton' onClick={onClickButton}>
        {text}
        <img className='logo' src={logo} alt="logo TruMarket" />
    </button>
}

export default BigButton