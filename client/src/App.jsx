import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import Header from './components/Header/Header'
import Footer from './components/Footer/Footer'
import Home from "./pages/Home/Home";
import Admin from "./pages/Admin/Admin";
import Marketplace from "./pages/Marketplace/Marketplace";
import Investor from "./pages/Investor/Investor";

import './App.scss';

function App() {
  return (
    <div className="App">
      <Header />
      <Routes>
        <Route exact path="/" element={<Home />} />
        <Route exact path="/admin" element={<Admin />} />
        <Route exact path="/marketplace" element={<Marketplace />} />
        <Route exact path="/investor" element={<Investor />} />
      </Routes>
      <Footer />
    </div>
  );
}

export default App;
