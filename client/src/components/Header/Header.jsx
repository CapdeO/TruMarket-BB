import React from 'react'
import './Header.scss'
import Dropdown from 'react-bootstrap/Dropdown';
import 'bootstrap/dist/css/bootstrap.css';

const Header = () => {
  return <div className='header'>
    <Dropdown>
      <Dropdown.Toggle variant="success" id="dropdown-basic">
        Admin
      </Dropdown.Toggle>

      <Dropdown.Menu>
        <Dropdown.Item href="#/action-1">Approve contracts</Dropdown.Item>
        <Dropdown.Item href="#/action-2">Manage NFTs</Dropdown.Item>
      </Dropdown.Menu>
    </Dropdown>

    <Dropdown>
      <Dropdown.Toggle variant="success" id="dropdown-basic">
        Investor
      </Dropdown.Toggle>

      <Dropdown.Menu>
        <Dropdown.Item href="#/action-1">Marketplace</Dropdown.Item>
        <Dropdown.Item href="#/action-2">My NFTs</Dropdown.Item>
      </Dropdown.Menu>
    </Dropdown>
    
  </div>
}

export default Header