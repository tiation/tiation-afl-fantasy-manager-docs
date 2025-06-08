# AFL Fantasy Manager API Documentation

## API Overview

The AFL Fantasy Manager API provides programmatic access to player statistics, team management, scoring, and league data. This document outlines the key aspects of the API and provides examples for common operations.

## Authentication

The API uses OAuth2 for authentication. To access the API, you need to:

1. Register for a developer account at https://fantasy.afl.com.au/developers
2. Create an application to receive your client ID and client secret
3. Implement the OAuth2 authorization flow to obtain access tokens

### Example Authentication Flow

```javascript
const fetch = require('node-fetch');

async function getAccessToken(clientId, clientSecret) {
  const response = await fetch('https://api.fantasy.afl.com.au/oauth/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      grant_type: 'client_credentials',
      client_id: clientId,
      client_secret: clientSecret,
    }),
  });

  const data = await response.json();
  return data.access_token;
}
```

## Core Endpoints

### Player Data

```
GET /api/v1/players
GET /api/v1/players/{playerId}
GET /api/v1/players/stats
```

### Team Management

```
GET /api/v1/teams
GET /api/v1/teams/{teamId}
POST /api/v1/teams
PUT /api/v1/teams/{teamId}
```

### Leagues

```
GET /api/v1/leagues
GET /api/v1/leagues/{leagueId}
POST /api/v1/leagues
GET /api/v1/leagues/{leagueId}/teams
```

### Fixtures & Results

```
GET /api/v1/fixtures
GET /api/v1/fixtures/{fixtureId}
GET /api/v1/results/round/{roundNumber}
```

## Request Examples

### Fetching Player Data

```javascript
async function getPlayerStats(accessToken, playerId) {
  const response = await fetch(`https://api.fantasy.afl.com.au/api/v1/players/${playerId}`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
  });

  return await response.json();
}
```

### Creating a Team

```javascript
async function createTeam(accessToken, teamData) {
  const response = await fetch('https://api.fantasy.afl.com.au/api/v1/teams', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(teamData),
  });

  return await response.json();
}
```

## Data Models

### Player Object

```json
{
  "id": 12345,
  "firstName": "Dustin",
  "lastName": "Martin",
  "teamId": 3,
  "teamName": "Richmond",
  "position": "MID",
  "price": 927000,
  "averagePoints": 105.3,
  "status": "available",
  "statistics": {
    "goals": 15,
    "disposals": 352,
    "marks": 78
    // Additional statistics...
  }
}
```

### Team Object

```json
{
  "id": 67890,
  "name": "My Fantasy Team",
  "ownerUserId": 5001,
  "salary": 13245000,
  "remainingSalary": 755000,
  "players": [
    {
      "playerId": 12345,
      "position": "MID"
    },
    // Additional players...
  ]
}
```

## Rate Limiting

The API enforces rate limits to ensure fair usage:

- 60 requests per minute for standard developers
- 120 requests per minute for premium developers
- 1,000 requests per day for free tier

Rate limit information is included in the response headers:

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 58
X-RateLimit-Reset: 1591234567
```

## Webhooks

Webhooks are available for real-time updates on:

- Player injury updates
- Score changes
- Team selection changes
- Round completion

To register a webhook, use the following endpoint:

```
POST /api/v1/webhooks
```

Payload example:

```json
{
  "url": "https://your-application.com/webhooks/fantasy",
  "events": ["player.injury", "team.selection", "round.complete"],
  "secret": "your_webhook_secret"
}
```

## Error Handling

The API uses standard HTTP status codes and provides error details in the response body:

```json
{
  "error": {
    "code": "invalid_team_composition",
    "message": "Team must have exactly 22 players",
    "details": [
      "Too few players in forward line",
      "Exceeded salary cap"
    ]
  }
}
```

## SDK Support

Official SDKs are available for:

- JavaScript/Node.js
- Python
- PHP

## Additional Resources

- [API Changelog](https://fantasy.afl.com.au/developers/changelog)
- [API Status Page](https://status.fantasy.afl.com.au)
- [Developer Forum](https://community.fantasy.afl.com.au/developers)

---

**Note**: This documentation is a placeholder with hypothetical endpoints. For accurate and up-to-date information, please refer to the official AFL Fantasy documentation.

