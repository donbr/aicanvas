import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import MagicCanvasDemo from './pages/MagicCanvas';
import PlaceholderPage from './pages/PlaceholderPage';
import NotFoundPage from './pages/NotFoundPage';

const App: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        // change to the route of a more useful page
        <Route path="/" element={<MagicCanvasDemo />} />
        <Route path="/PlaceholderPage" element={<PlaceholderPage />} />        

        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  );
};

export default App;
