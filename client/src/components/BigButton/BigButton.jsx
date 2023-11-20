import React from 'react'
import './BigButton.scss'
import logo from '../../assets/logo.png'
import Fade from 'react-reveal/Fade';

const BigButton = ({ text, onClickButton, direction }) => {
    return<Fade 
        left={direction === 'left'} 
        right={direction === 'right'}
        top={direction === 'top'}
        bottom={direction === 'bottom'}
        >

        <button className='bigButton' onClick={onClickButton}>
            {text}
            <img className='logo' src={logo} alt="logo TruMarket" />
        </button>
    </Fade>
    
    
}

export default BigButton