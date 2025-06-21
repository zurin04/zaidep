# Crypto Airdrop Platform

A comprehensive crypto learning and engagement platform for discovering airdrops, tasks, and rewards.

## Features

- **User Management**: Registration, authentication, and Web3 wallet integration
- **Airdrop Discovery**: Browse and track cryptocurrency airdrops
- **Creator System**: Role-based access for content creators
- **Real-time Chat**: Live community discussions
- **Admin Dashboard**: Complete platform management
- **Crypto Price Tracking**: Live market data integration

## Tech Stack

- **Frontend**: React, TypeScript, Tailwind CSS, Framer Motion
- **Backend**: Express.js, PostgreSQL, Drizzle ORM
- **Authentication**: Passport.js + Web3 wallet support
- **Real-time**: WebSocket connections
- **Deployment**: Ubuntu Server with Nginx

## Development Setup

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Set up database**
   ```bash
   npm run db:push
   npm run db:seed
   ```

3. **Start development server**
   ```bash
   npm run dev
   ```

   The application will be available at `http://localhost:5000`

## Production Deployment

For Ubuntu servers, use the provided deployment script:

```bash
sudo bash deploy.sh
```

See `DEPLOYMENT.md` for detailed production setup instructions.

## Environment Variables

- `DATABASE_URL` - PostgreSQL connection string
- `SESSION_SECRET` - Session encryption key
- `NODE_ENV` - Environment (development/production)

## Project Structure

```
├── client/          # React frontend
├── server/          # Express backend
├── shared/          # Shared schema and types
├── db/              # Database configuration
├── deploy.sh        # Ubuntu deployment script
└── DEPLOYMENT.md    # Production setup guide
```

## Default Admin Credentials

- Username: `admin`
- Password: `admin123`

**Important**: Change these credentials immediately after first login.

## License

MIT License