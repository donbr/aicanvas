import React, { useState } from 'react';
import { Camera, MessageSquare } from 'lucide-react';

// Simple approximation of the MagicCanvas for demo purposes
const MagicCanvasDemo = () => {
  const [image, setImage] = useState('https://placehold.co/800x600');
  const [regions, setRegions] = useState([]);
  const [activeRegion, setActiveRegion] = useState(null);
  const [selectionMode, setSelectionMode] = useState('rectangle');
  const [isSelecting, setIsSelecting] = useState(false);
  const [showChat, setShowChat] = useState(false);
  const [question, setQuestion] = useState('');
  const [answer, setAnswer] = useState('');
  
  // Demo handling region creation
  const handleCreateRegion = () => {
    // In real implementation, this would come from actual user selection
    const newRegion = {
      id: `region_${regions.length + 1}`,
      type: selectionMode === 'rectangle' ? 'rectangle' : 'polygon',
      data: selectionMode === 'rectangle' 
        ? { x: 100, y: 100, width: 200, height: 150 } 
        : { 
            points: [
              {x: 400, y: 150}, 
              {x: 500, y: 200}, 
              {x: 450, y: 300}, 
              {x: 350, y: 250}
            ],
            bounds: { x: 350, y: 150, width: 150, height: 150 }
          }
    };
    
    setRegions([...regions, newRegion]);
    setActiveRegion(newRegion.id);
  };
  
  // Demo asking a question
  const handleAskQuestion = () => {
    if (!question.trim()) return;
    
    setAnswer("This appears to be a mountain landscape with a lake in the foreground. The mountains have snow-capped peaks and there are some trees visible around the lake's edge. The image shows a beautiful natural scene, likely taken in a national park or wilderness area.");
    setShowChat(true);
  };
  
  return (
    <div className="flex flex-col bg-white rounded-lg shadow-lg w-full max-w-4xl mx-auto overflow-hidden">
      {/* Header */}
      <div className="p-4 border-b flex justify-between items-center">
        <div className="text-xl font-semibold text-gray-700">AI Canvas Demo</div>
        <div className="flex space-x-3">
          <button 
            className={`px-3 py-1 rounded-md ${selectionMode === 'rectangle' ? 'bg-blue-500 text-white' : 'bg-gray-200'}`}
            onClick={() => setSelectionMode('rectangle')}
          >
            Rectangle
          </button>
          <button 
            className={`px-3 py-1 rounded-md ${selectionMode === 'lasso' ? 'bg-blue-500 text-white' : 'bg-gray-200'}`}
            onClick={() => setSelectionMode('lasso')}
          >
            Lasso
          </button>
        </div>
      </div>
      
      {/* Main content */}
      <div className="flex flex-grow relative">
        {/* Canvas area */}
        <div className="w-full h-96 md:h-[500px] relative bg-gray-100 flex-grow">
          <img 
            src={image} 
            alt="Canvas content" 
            className="w-full h-full object-contain"
          />
          
          {/* Demo regions */}
          {regions.map(region => (
            <div 
              key={region.id}
              className={`absolute border-2 ${activeRegion === region.id ? 'border-blue-500 bg-blue-100 bg-opacity-30' : 'border-blue-300'}`}
              style={
                region.type === 'rectangle' 
                  ? {
                      left: `${region.data.x}px`,
                      top: `${region.data.y}px`,
                      width: `${region.data.width}px`,
                      height: `${region.data.height}px`,
                    }
                  : {
                      left: `${region.data.bounds.x}px`,
                      top: `${region.data.bounds.y}px`,
                      width: `${region.data.bounds.width}px`,
                      height: `${region.data.bounds.height}px`,
                      clipPath: 'polygon(30% 0%, 100% 30%, 70% 100%, 0% 70%)'
                    }
              }
              onClick={() => setActiveRegion(region.id)}
            />
          ))}
          
          {/* Demo selection */}
          {isSelecting && (
            <div className="absolute border-2 border-dashed border-blue-500 bg-blue-100 bg-opacity-20"
                 style={{ left: '300px', top: '200px', width: '150px', height: '100px' }} />
          )}
          
          {/* Tools */}
          <div className="absolute bottom-4 left-4 bg-white rounded-lg shadow p-2 flex space-x-2">
            <button 
              className="p-2 rounded hover:bg-gray-100"
              onClick={handleCreateRegion}
              title="Add demo region"
            >
              <Camera size={20} />
            </button>
            <button 
              className={`p-2 rounded hover:bg-gray-100 ${showChat ? 'text-blue-500' : ''}`}
              onClick={() => setShowChat(!showChat)}
              title="Toggle chat"
            >
              <MessageSquare size={20} />
            </button>
          </div>
        </div>
        
        {/* Chat sidebar */}
        {showChat && (
          <div className="w-full md:w-80 border-l flex flex-col">
            <div className="p-3 border-b font-medium">Ask about this region</div>
            <div className="flex-grow p-3 overflow-auto bg-gray-50">
              {answer && (
                <div className="bg-blue-100 p-3 rounded-lg mb-3">
                  {answer}
                </div>
              )}
            </div>
            <div className="p-3 border-t">
              <input
                type="text"
                className="w-full p-2 border rounded-md"
                placeholder="Ask a question..."
                value={question}
                onChange={(e) => setQuestion(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && handleAskQuestion()}
              />
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default MagicCanvasDemo;
