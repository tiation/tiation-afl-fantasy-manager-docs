# AFL Fantasy Manager Developer Guide

## Getting Started

This guide provides developers with instructions for setting up a development environment and working with the AFL Fantasy Manager platform.

## Prerequisites

- Node.js (v14+)
- npm or yarn
- PostgreSQL (v12+)
- Redis (for caching)
- Git
- AWS CLI (for deployment)

## Local Development Setup

### 1. Clone the Repository

```bash
# Replace with actual repository URL when available
git clone https://github.com/afl-fantasy/fantasy-manager.git
cd fantasy-manager
```

### 2. Install Dependencies

```bash
# Install backend dependencies
cd server
npm install

# Install frontend dependencies
cd ../client
npm install
```

### 3. Configure Environment

```bash
# Copy example environment files
cp .env.example .env
```

Edit the `.env` file to include your local database connection, API keys, and other configuration options.

### 4. Set Up the Database

```bash
# Run database migrations
npm run migrate

# Seed the database with sample data
npm run seed
```

### 5. Start the Development Server

```bash
# Start the backend server
cd server
npm run dev

# In a separate terminal, start the frontend
cd client
npm start
```

The application should now be running at `http://localhost:3000`.

## Project Structure

```
fantasy-manager/
├── client/                 # Frontend React application
│   ├── public/             # Static assets
│   ├── src/                # React source code
│   │   ├── components/     # UI components
│   │   ├── pages/          # Page components
│   │   ├── services/       # API client services
│   │   ├── store/          # State management
│   │   └── utils/          # Utility functions
│   └── package.json        # Frontend dependencies
│
├── server/                 # Backend Node.js application
│   ├── src/                # Server source code
│   │   ├── controllers/    # Request handlers
│   │   ├── models/         # Data models
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic
│   │   └── utils/          # Utility functions
│   ├── migrations/         # Database migrations
│   ├── seeds/              # Database seed data
│   └── package.json        # Backend dependencies
│
├── docs/                   # Documentation
├── tests/                  # Test suites
└── README.md               # Project overview
```

## API Usage Examples

### Authentication

```javascript
// Example: Log in and get access token
async function login(email, password) {
  const response = await fetch('http://localhost:4000/api/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password }),
  });
  
  const data = await response.json();
  
  // Store the token for future requests
  localStorage.setItem('accessToken', data.accessToken);
  
  return data;
}
```

### Fetching Player Data

```javascript
// Example: Get all players
async function getPlayers() {
  const token = localStorage.getItem('accessToken');
  
  const response = await fetch('http://localhost:4000/api/players', {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  });
  
  return await response.json();
}

// Example: Get a specific player
async function getPlayer(playerId) {
  const token = localStorage.getItem('accessToken');
  
  const response = await fetch(`http://localhost:4000/api/players/${playerId}`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  });
  
  return await response.json();
}
```

### Creating a Team

```javascript
// Example: Create a new team
async function createTeam(teamData) {
  const token = localStorage.getItem('accessToken');
  
  const response = await fetch('http://localhost:4000/api/teams', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(teamData),
  });
  
  return await response.json();
}
```

## Common Development Tasks

### Running Tests

```bash
# Run backend tests
cd server
npm test

# Run frontend tests
cd client
npm test
```

### Database Migrations

```bash
# Create a new migration
cd server
npm run migrate:make migration_name

# Run migrations
npm run migrate

# Rollback the latest migration
npm run migrate:rollback
```

### Building for Production

```bash
# Build the frontend
cd client
npm run build

# Prepare the backend
cd ../server
npm run build
```

## Deployment

### AWS Deployment

1. Set up AWS credentials

```bash
aws configure
```

2. Deploy using the deployment script

```bash
./scripts/deploy.sh production
```

## Development Guidelines

### Code Style

- Follow the ESLint configuration in the project
- Use Prettier for consistent formatting
- Write meaningful commit messages following conventional commits format

### Pull Request Process

1. Create a feature branch from `develop`
2. Make your changes and commit them
3. Push your branch and create a pull request to `develop`
4. Ensure tests pass and code meets quality standards
5. Get at least one code review approval
6. Merge the pull request

### Documentation

- Document all API endpoints using JSDoc
- Keep README files up to date
- Document complex algorithms and business logic

## Troubleshooting

### Common Issues

#### Database Connection Problems

```
Error: Could not connect to database
```

Solution: Check your database credentials in the `.env` file and ensure PostgreSQL is running.

#### API Authentication Failures

```
Error: Invalid token
```

Solution: Ensure you're passing the correct token in the Authorization header and that it hasn't expired.

## Resources

- [AFL Fantasy API Documentation](https://fantasy.afl.com.au/developers)
- [React Documentation](https://reactjs.org/docs/getting-started.html)
- [Node.js Documentation](https://nodejs.org/en/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

**Note**: This developer guide is a placeholder with hypothetical instructions. For accurate and up-to-date development information, please refer to the official AFL Fantasy Manager documentation when available.

