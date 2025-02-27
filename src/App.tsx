import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import CytoscapeGraphExplorer from './pages/CytoscapeGraphExplorer';
import TemporalGraphExplorer from './pages/TemporalGraphExplorer';
import PlaceholderPage from './pages/PlaceholderPage';
import NotFoundPage from './pages/NotFoundPage';

const App: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        // change to the route of a more useful page
        <Route path="/" element={<PlaceholderPage />} />
        <Route path="/CytoscapeGraphExplorer" element={<CytoscapeGraphExplorer />} />
        <Route path="/TemporalGraphExplorer" element={<TemporalGraphExplorer />} />        

        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  );
};

export default App;
