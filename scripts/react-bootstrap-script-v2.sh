#!/bin/bash
# Bootstrap a lightweight React application with Vite, TypeScript, Tailwind CSS, and React Router
# Based on Anthropic Quickstarts best practices

set -e # Exit on error

# Check for required tools
command -v npm >/dev/null 2>&1 || { echo >&2 "Error: npm is required but not installed. Aborting."; exit 1; }
command -v git >/dev/null 2>&1 || { echo >&2 "Warning: git is not installed. Repository initialization will be skipped."; GIT_MISSING=true; }
command -v node >/dev/null 2>&1 || { echo >&2 "Error: node is required but not installed. Aborting."; exit 1; }

# Check Node.js version (minimum v18.17.0 as per Anthropic Quickstarts)
NODE_VERSION=$(node -v | cut -d "v" -f 2)
NODE_MAJOR=$(echo $NODE_VERSION | cut -d "." -f 1)
NODE_MINOR=$(echo $NODE_VERSION | cut -d "." -f 2)

if [ "$NODE_MAJOR" -lt 18 ] || [[ "$NODE_MAJOR" -eq 18 && "$NODE_MINOR" -lt 17 ]]; then
  echo >&2 "Error: Node.js v18.17.0 or higher is required. Current version: $NODE_VERSION"
  exit 1
fi

# Colors for terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Lightweight React App Bootstrapper    ${NC}"
echo -e "${BLUE}=========================================${NC}"

# Prompt for project name with validation
while true; do
  read -p "Enter project name (alphanumeric, hyphens and underscores only): " PROJECT_NAME
  if [[ ! $PROJECT_NAME =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Error: Project name must contain only letters, numbers, hyphens and underscores."
    continue
  fi
  
  if [ -d "$PROJECT_NAME" ]; then
    read -p "Directory '$PROJECT_NAME' already exists. Overwrite? (y/n): " OVERWRITE
    if [[ $OVERWRITE =~ ^[Yy]$ ]]; then
      echo "Removing existing directory..."
      rm -rf "$PROJECT_NAME"
    else
      echo "Please choose a different project name."
      continue
    fi
  fi
  
  break
done

PROJECT_DIR="./${PROJECT_NAME}"

# Create project with Vite
echo -e "\n${YELLOW}Creating new Vite + React + TypeScript project...${NC}"
npm create vite@latest ${PROJECT_NAME} -- --template react-ts

cd ${PROJECT_DIR}

# Install core dependencies
echo -e "\n${YELLOW}Installing core dependencies...${NC}"
npm install

# Install Tailwind CSS and its peer dependencies
echo -e "\n${YELLOW}Setting up Tailwind CSS...${NC}"
npm install -D tailwindcss@^3.4.1 @tailwindcss/postcss@^4.0.8 postcss@^8 autoprefixer@^10.4.16
npx tailwindcss init -p

# Configure Tailwind
cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{ts,tsx,js,jsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF

# Add Tailwind directives to CSS
cat > src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --foreground-rgb: 0, 0, 0;
  --background-rgb: 255, 255, 255;
}

@media (prefers-color-scheme: dark) {
  :root {
    --foreground-rgb: 255, 255, 255;
    --background-rgb: 10, 10, 10;
  }
}

body {
  color: rgb(var(--foreground-rgb));
  background-color: rgb(var(--background-rgb));
}
EOF

# Install path alias support
echo -e "\n${YELLOW}Setting up path aliases...${NC}"
npm install -D @types/node

# Configure path aliases
cat > vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
    },
  },
})
EOF

# Install React Router and Lucide React
echo -e "\n${YELLOW}Installing React Router and UI dependencies...${NC}"
npm install react-router-dom lucide-react

# Create directory structure
echo -e "\n${YELLOW}Setting up directory structure...${NC}"
mkdir -p src/pages
mkdir -p src/components/ui
mkdir -p src/layouts
mkdir -p src/lib

# Create utils.ts file
cat > src/lib/utils.ts << 'EOF'
import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
EOF

# Install additional dependencies
npm install clsx class-variance-authority tailwind-merge

# Create a Placholder page
cat > src/pages/PlaceholderPage.tsx << 'EOF'
import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

const PlaceholderPage: React.FC = () => {
  const [currentPhrase, setCurrentPhrase] = useState('');
  const [phraseIndex, setPhraseIndex] = useState(0);
  const [charIndex, setCharIndex] = useState(0);
  const [isDeleting, setIsDeleting] = useState(false);
  const [cursorVisible, setCursorVisible] = useState(true);
  const [bgPosition, setBgPosition] = useState({ x: 0, y: 0 });
  
  const phrases = [
    "This is not the page you are looking for...",
    "But perhaps it's the one you need...",
    "Creating something extraordinary...",
    "Building the next breakthrough...",
    "Innovation starts here..."
  ];

  // Typing effect
  useEffect(() => {
    const typingSpeed = isDeleting ? 30 : 100;
    const timer = setTimeout(() => {
      if (!isDeleting && charIndex < phrases[phraseIndex].length) {
        setCurrentPhrase(prev => prev + phrases[phraseIndex][charIndex]);
        setCharIndex(charIndex + 1);
      } else if (isDeleting && charIndex > 0) {
        setCurrentPhrase(phrases[phraseIndex].substring(0, charIndex - 1));
        setCharIndex(charIndex - 1);
      } else if (charIndex === phrases[phraseIndex].length) {
        setTimeout(() => setIsDeleting(true), 1500);
      } else if (charIndex === 0 && isDeleting) {
        setIsDeleting(false);
        setPhraseIndex((phraseIndex + 1) % phrases.length);
      }
    }, typingSpeed);

    return () => clearTimeout(timer);
  }, [charIndex, isDeleting, phraseIndex, phrases]);

  // Cursor blinking effect
  useEffect(() => {
    const cursorTimer = setInterval(() => {
      setCursorVisible(prev => !prev);
    }, 500);

    // Add animation styles to document head
    const styleEl = document.createElement('style');
    styleEl.innerHTML = `
      @keyframes float {
        0% {
          transform: translateY(0) translateX(0);
          opacity: 0;
        }
        10% {
          opacity: 0.3;
        }
        90% {
          opacity: 0.3;
        }
        100% {
          transform: translateY(-1000px) translateX(100px);
          opacity: 0;
        }
      }
    `;
    document.head.appendChild(styleEl);

    return () => {
      clearInterval(cursorTimer);
      document.head.removeChild(styleEl);
    };
  }, []);

  // Interactive background movement
  const handleMouseMove = (e: React.MouseEvent) => {
    const x = e.clientX / window.innerWidth;
    const y = e.clientY / window.innerHeight;
    setBgPosition({ x, y });
  };

  return (
    <div 
      onMouseMove={handleMouseMove}
      className="relative flex flex-col items-center justify-center min-h-screen w-full overflow-hidden py-20 bg-gradient-to-br from-indigo-900 via-purple-800 to-pink-700"
      style={{
        backgroundPosition: `${bgPosition.x * 10}% ${bgPosition.y * 10}%`,
        transition: 'background-position 0.2s ease-out'
      }}
    >
      {/* Animated particles */}
      <div className="absolute inset-0 overflow-hidden">
        {[...Array(20)].map((_, i) => (
          <div 
            key={i}
            className="absolute rounded-full bg-white opacity-30"
            style={{
              top: `${Math.random() * 100}%`,
              left: `${Math.random() * 100}%`,
              width: `${Math.random() * 50 + 10}px`,
              height: `${Math.random() * 50 + 10}px`,
              animation: `float ${Math.random() * 10 + 15}s linear infinite`,
              animationDelay: `${Math.random() * 5}s`
            }}
          />
        ))}
      </div>

      <div className="z-10 text-center px-4 max-w-2xl backdrop-blur-sm bg-black/20 p-8 rounded-lg shadow-2xl border border-white/20">
        <h1 className="text-5xl font-bold text-white mb-8 animate-pulse">
          404 <span className="text-pink-400">Wormhole</span>
        </h1>
        
        <div className="h-20 flex items-center justify-center mb-8">
          <h2 className="text-2xl font-bold text-white">
            {currentPhrase}
            <span className={`ml-1 ${cursorVisible ? 'opacity-100' : 'opacity-0'} transition-opacity`}>|</span>
          </h2>
        </div>
        
        <div className="space-y-6">
          <p className="text-lg text-gray-200 mb-8">
            While you're here, why not explore something amazing?
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link 
              to="https://www.anthropic.com/news/claude-3-7-sonnet" 
              className="bg-purple-600 text-white px-6 py-3 rounded-md hover:bg-purple-500 transition-colors duration-300 shadow-lg transform hover:scale-105 flex items-center justify-center"
            >
              <span className="mr-2">🤖</span> Claude 3.7 Sonnet
            </Link>
            
            <Link 
              to="/" 
              className="bg-pink-600 text-white px-6 py-3 rounded-md hover:bg-pink-500 transition-colors duration-300 shadow-lg transform hover:scale-105 flex items-center justify-center"
            >
              <span className="mr-2">🏠</span> Return Home
            </Link>
          </div>
        </div>
      </div>

      {/* Easter egg - hidden interactive element */}
      <div 
        className="absolute bottom-4 right-4 w-8 h-8 rounded-full bg-white/10 hover:bg-white/30 cursor-pointer transition-all duration-300 flex items-center justify-center text-white/50 hover:text-white"
        onClick={() => alert('You found the secret! The universe acknowledges your curiosity.')}
        title="What happens if you click me?"
      >
        ?
      </div>


    </div>
  );
};

export default PlaceholderPage;
EOF

# Create a sample NotFound page
cat > src/pages/NotFoundPage.tsx << 'EOF'
import React from 'react';
import { Link } from 'react-router-dom';

const NotFoundPage: React.FC = () => {
  return (
    <div className="flex flex-col items-center justify-center py-20">
      <h1 className="text-4xl font-bold text-gray-800 mb-4">404 - Page Not Found</h1>
      <p className="text-lg text-gray-600 mb-8">The page you are looking for doesn't exist or has been moved.</p>
      <Link to="/" className="bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-500">
        Go Home
      </Link>
    </div>
  );
};

export default NotFoundPage;
EOF

# Update App.tsx with React Router setup
cat > src/App.tsx << 'EOF'
import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import PlaceholderPage from './pages/PlaceholderPage';
import NotFoundPage from './pages/NotFoundPage';

const App: React.FC = () => {
  return (
    <BrowserRouter>
      <Routes>
        // change to the route of a more useful page
        <Route path="/" element={<PlaceholderPage />} />

        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  );
};

export default App;
EOF

# Create a proper .gitignore file
cat > .gitignore << 'EOF'
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*

node_modules
dist
dist-ssr
*.local

# Editor directories and files
.vscode/*
!.vscode/extensions.json
.idea
.DS_Store
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?

# Environment variables
.env
.env.*
!.env.example
EOF

# Optionally, initialize git if it's available
if [ "${GIT_MISSING}" != "true" ]; then
  echo -e "\n${YELLOW}Initializing git repository...${NC}"
  git init
  git checkout -b main
  git add .
  git commit -m "Initial commit: Bootstrap React app with React Router"
else
  echo -e "\n${YELLOW}Skipping git initialization (git not found)${NC}"
fi

# Create a README.md file
cat > README.md << EOF
# ${PROJECT_NAME}

A React application with React Router, bootstrapped with Vite, TypeScript, and Tailwind CSS.

## Getting Started

First, install the dependencies:

\`\`\`bash
npm install
\`\`\`

Then, run the development server:

\`\`\`bash
npm run dev
\`\`\`

Open [http://localhost:5173](http://localhost:5173) with your browser to see the result.

## Features

- React 18 with TypeScript
- React Router for navigation
- Vite for fast builds and development
- Tailwind CSS for styling
- Path aliases for clean imports
- Responsive design with dark mode support

## Project Structure

- \`src/pages/\`: Page components that correspond to routes
- \`src/components/\`: Reusable UI components
- \`src/layouts/\`: Layout components for page structure
- \`src/lib/\`: Utility functions and shared logic

## Learn More

- [React Router Documentation](https://reactrouter.com/)
- [Vite Documentation](https://vitejs.dev/)
- [React Documentation](https://react.dev/)
- [Tailwind CSS Documentation](https://tailwindcss.com/)
EOF

echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}  Project setup complete!               ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "Run these commands to start development:"
echo -e "  ${BLUE}cd ${PROJECT_NAME}${NC}"
echo -e "  ${BLUE}npm run dev${NC}"
echo -e "\nAccess the app at: ${BLUE}http://localhost:5173${NC}"
echo -e "\nHappy coding! 🚀"