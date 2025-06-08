#!/bin/bash
# AFL Fantasy Manager Project Organization Implementation Script

# Define color codes for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define base directories
PROJECT_DIR="/home/lappy/ProJects2/AflFantasyManager/AFLFantasyConsolidatedMAIN"
TEMP_DIR="/tmp/afl_fantasy_temp"

echo -e "${BLUE}AFL Fantasy Manager Project Organization Script${NC}"
echo -e "${YELLOW}This script will organize your project according to the defined structure.${NC}"
echo "Project directory: $PROJECT_DIR"

# Confirm before proceeding
read -p "Do you want to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Operation cancelled."
    exit 1
fi

# Step 1: Create a temporary backup
echo -e "${YELLOW}Creating temporary backup...${NC}"
mkdir -p $TEMP_DIR
cp -r $PROJECT_DIR/* $TEMP_DIR/
echo -e "${GREEN}Backup created at $TEMP_DIR${NC}"

# Step 2: Create directory structure
echo -e "${YELLOW}Creating directory structure...${NC}"
cd $PROJECT_DIR

mkdir -p client/src/{components,hooks,pages,services,utils} \
         client/public \
         server/api/tools \
         server/scraping/spiders \
         server/data \
         server/utils \
         docs/{api,development,user} \
         tests/{client,server,e2e} \
         docker/{client,server} \
         scripts \
         .github/workflows

echo -e "${GREEN}Directory structure created.${NC}"

# Step 3: Move existing frontend files to new structure
echo -e "${YELLOW}Organizing frontend files...${NC}"

# Process client files - We'll need to organize UI files from the multiple implementations
if [ -d "$PROJECT_DIR/client/ui" ]; then
    # Main UI implementation
    echo "Processing main UI implementation..."
    
    # Find the main UI implementation (using the AFL Fantasy one)
    MAIN_UI=$(find client/ui -type d -name "afl-fantasy-*" | head -1)
    
    if [ ! -z "$MAIN_UI" ]; then
        # Copy components
        echo "Copying components..."
        find $MAIN_UI -path "*/src/components/*" -type f -exec cp {} client/src/components/ \;
        
        # Copy hooks
        echo "Copying hooks..."
        find $MAIN_UI -path "*/src/hooks/*" -type f -exec cp {} client/src/hooks/ \;
        
        # Copy pages
        echo "Copying pages..."
        find $MAIN_UI -path "*/src/pages/*" -type f -exec cp {} client/src/pages/ \;
        
        # Copy public assets
        echo "Copying public assets..."
        find $MAIN_UI -path "*/public/*" -type f -exec cp {} client/public/ \;
    else
        echo "Main UI implementation not found. Skipping."
    fi
    
    # Create a consolidated package.json
    echo "Creating consolidated package.json..."
    cat > client/package.json << 'PACKAGEJSON'
{
  "name": "afl-fantasy-manager",
  "version": "1.0.0",
  "description": "AFL Fantasy Manager - Full Stack Tool Suite",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "lint": "eslint src --ext ts,tsx",
    "test": "jest",
    "preview": "vite preview"
  },
  "dependencies": {
    "axios": "^1.6.0",
    "chart.js": "^4.4.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.18.0",
    "tailwindcss": "^3.3.5"
  },
  "devDependencies": {
    "@types/react": "^18.2.15",
    "@types/react-dom": "^18.2.7",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "@vitejs/plugin-react": "^4.0.3",
    "eslint": "^8.45.0",
    "jest": "^29.7.0",
    "typescript": "^5.0.2",
    "vite": "^4.4.5"
  }
}
PACKAGEJSON
fi

# Step 4: Move existing backend files to new structure
echo -e "${YELLOW}Organizing backend files...${NC}"

# Move scrapers
if [ -d "$PROJECT_DIR/server/scraping" ]; then
    echo "Moving scrapers..."
    cp $PROJECT_DIR/scrapy_afl_fantasy_extended_spider.py server/scraping/spiders/
    cp $PROJECT_DIR/run_spider.py server/scraping/
fi

# Process API files
if [ -d "$PROJECT_DIR/server/api" ]; then
    echo "Processing API files..."
    find server/api -type f -name "*.py" -exec cp {} server/api/ \;
fi

# Create consolidated requirements.txt
echo "Creating consolidated requirements.txt..."
cat > server/requirements.txt << 'REQUIREMENTS'
# Web Framework
flask==2.3.2
flask-cors==4.0.0
flask-jwt-extended==4.5.2

# Data Processing
pandas==2.0.3
numpy==1.25.2
scikit-learn==1.3.0

# Web Scraping
scrapy==2.10.0
requests==2.31.0

# Database
sqlalchemy==2.0.20
alembic==1.12.0

# Utilities
python-dotenv==1.0.0
pydantic==2.3.0
pytest==7.4.2
REQUIREMENTS

# Step 5: Create Docker files
echo -e "${YELLOW}Creating Docker files...${NC}"

# Create docker-compose.yml
cat > docker-compose.yml << 'DOCKERCOMPOSE'
version: '3.8'

services:
  client:
    build:
      context: ./docker/client
    ports:
      - "3000:80"
    depends_on:
      - server
    volumes:
      - ./client:/app
    environment:
      - VITE_API_URL=http://localhost:5000

  server:
    build:
      context: ./docker/server
    ports:
      - "5000:5000"
    volumes:
      - ./server:/app
    environment:
      - FLASK_ENV=development
      - FLASK_APP=app.py
      - DATABASE_URL=sqlite:///./data/afl_fantasy.db

volumes:
  data:
DOCKERCOMPOSE

# Create client Dockerfile
mkdir -p docker/client
cat > docker/client/Dockerfile << 'DOCKERFILE'
FROM node:18-alpine

WORKDIR /app

COPY client/package.json ./
RUN npm install

COPY client .
RUN npm run build

FROM nginx:alpine
COPY --from=0 /app/dist /usr/share/nginx/html
COPY docker/client/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
DOCKERFILE

# Create Nginx config
cat > docker/client/nginx.conf << 'NGINXCONF'
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://server:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
NGINXCONF

# Create server Dockerfile
mkdir -p docker/server
cat > docker/server/Dockerfile << 'DOCKERFILE'
FROM python:3.11-slim

WORKDIR /app

COPY server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY server .

EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0"]
DOCKERFILE

# Step 6: Create setup scripts
echo -e "${YELLOW}Creating setup scripts...${NC}"

# Create setup.sh
cat > scripts/setup.sh << 'SETUPSCRIPT'
#!/bin/bash

# AFL Fantasy Manager Setup Script
echo "Setting up AFL Fantasy Manager..."

# Install frontend dependencies
echo "Installing frontend dependencies..."
cd client
npm install
cd ..

# Install backend dependencies
echo "Setting up Python virtual environment..."
cd server
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cd ..

# Create .env file
echo "Creating .env file..."
cp .env.example .env

echo "Setup complete! You can now run the application."
echo "To start the frontend: cd client && npm run dev"
echo "To start the backend: cd server && flask run --debug"
SETUPSCRIPT

# Create deploy.sh
cat > scripts/deploy.sh << 'DEPLOYSCRIPT'
#!/bin/bash

# AFL Fantasy Manager Deployment Script
echo "Deploying AFL Fantasy Manager..."

# Build and deploy with Docker Compose
docker-compose up -d --build

echo "Deployment complete! The application is running at http://localhost:3000"
DEPLOYSCRIPT

# Make scripts executable
chmod +x scripts/setup.sh scripts/deploy.sh

# Step 7: Move documentation files
echo -e "${YELLOW}Organizing documentation files...${NC}"

# Create documentation index
mkdir -p docs/api
cp $PROJECT_DIR/API_REFERENCE.md docs/api/
cp $PROJECT_DIR/QUICK_REFERENCE.md docs/api/

mkdir -p docs/development
cp $PROJECT_DIR/CODING_STANDARDS.md docs/development/
cp $PROJECT_DIR/COMMON_PATTERNS.md docs/development/

mkdir -p docs/user
cp $PROJECT_DIR/README.md docs/user/
cp $PROJECT_DIR/DOCUMENTATION.md docs/

# Step 8: Create .env.example
echo -e "${YELLOW}Creating environment file template...${NC}"

cat > .env.example << 'ENVEXAMPLE'
# API Configuration
API_PORT=5000
NODE_ENV=development

# Database Configuration
DATABASE_URL=sqlite:///./data/afl_fantasy.db

# Authentication
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRATION=3600

# External APIs
AFL_FANTASY_API_KEY=your_api_key_here
WEATHER_API_KEY=your_api_key_here

# Feature Flags
ENABLE_ML_PREDICTIONS=true
ENABLE_LIVE_UPDATES=true
ENVEXAMPLE

# Step 9: Create a new README.md in the root
echo -e "${YELLOW}Creating new README.md...${NC}"

cat > README.md << 'README'
# AFL Fantasy Manager

<p align="center">
  <img src="client/public/afl-fantasy-logo.png" alt="AFL Fantasy Logo" width="200"/>
</p>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python Version](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![React Version](https://img.shields.io/badge/react-18.0+-61DAFB.svg)](https://reactjs.org/)
[![Flask Version](https://img.shields.io/badge/flask-2.0+-000000.svg)](https://flask.palletsprojects.com/)

## 📋 Overview

AFL Fantasy Tool Suite is a comprehensive full-stack application designed to give Australian Football League (AFL) fantasy players a competitive edge through advanced analytics, real-time data processing, and predictive modeling.

## 🚀 Getting Started

### Development Setup

1. Clone the repository
```bash
git clone https://gitlab.tiation.net/tia/AflFantasyManager.git
cd AflFantasyManager
```

2. Run the setup script
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

3. Start the development servers
```bash
# In one terminal
cd client && npm run dev

# In another terminal
cd server && flask run --debug
```

### Production Deployment

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

## 📁 Project Structure

```
AFLFantasyManager/
├── client/                 # Frontend applications
├── server/                 # Backend applications
├── docs/                   # Documentation
├── tests/                  # Test suites
├── docker/                 # Docker configuration
├── scripts/                # Utility scripts
├── .github/                # GitHub configuration
├── .env.example            # Example environment variables
├── docker-compose.yml      # Docker Compose configuration
├── README.md               # Project documentation
└── LICENSE                 # License file
```

## 📚 Documentation

- [API Reference](docs/api/API_REFERENCE.md)
- [Development Guidelines](docs/development/CODING_STANDARDS.md)
- [User Guide](docs/user/README.md)

## 🤝 Contributing

Please read [CONTRIBUTING.md](docs/development/CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
README

# Step 10: Set file permissions
echo -e "${YELLOW}Setting file permissions...${NC}"
find scripts -type f -name "*.sh" -exec chmod +x {} \;

# Final message
echo -e "${GREEN}Project organization complete!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review the organized structure"
echo "2. Add your code to the appropriate directories"
echo "3. Run scripts/setup.sh to set up the development environment"
echo "4. Start developing!"
echo
echo -e "${BLUE}Temporary backup is available at: ${TEMP_DIR}${NC}"
