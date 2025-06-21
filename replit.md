# Crypto Airdrop Platform

## Overview

A comprehensive cryptocurrency airdrop discovery platform built with modern web technologies. The platform enables users to explore, learn about, and participate in cryptocurrency airdrops through step-by-step tutorials, real-time community chat, and advanced user management features.

## System Architecture

### Frontend Architecture
- **Framework**: React 18 with TypeScript for type safety
- **Build Tool**: Vite for fast development and optimized builds
- **Styling**: Tailwind CSS with shadcn/ui component library for consistent design
- **State Management**: TanStack Query for server state management
- **Routing**: Wouter for lightweight client-side routing
- **Animation**: Framer Motion for smooth UI transitions
- **Form Handling**: React Hook Form with Zod validation

### Backend Architecture
- **Runtime**: Node.js 20 with TypeScript
- **Framework**: Express.js for RESTful API endpoints
- **Database**: PostgreSQL with Drizzle ORM for type-safe database operations
- **Authentication**: Passport.js with support for traditional and Web3 wallet authentication (SIWE)
- **Session Management**: Express-session with PostgreSQL store
- **Real-time Communication**: WebSocket server for live chat functionality
- **File Upload**: Multer for handling image uploads

## Key Components

### Authentication System
- **Traditional Auth**: Username/password authentication with bcrypt hashing
- **Web3 Integration**: Ethereum wallet connection using Sign-In with Ethereum (SIWE)
- **Role-based Access**: Admin, Creator, and User roles with different permissions
- **Session Security**: Secure session management with configurable expiration

### Database Schema
- **Users**: Core user data with Web3 wallet support and role management
- **Airdrops**: Comprehensive airdrop information with categorization and tracking
- **Categories**: Organizational structure for airdrop classification
- **Creator Applications**: System for users to apply for creator status
- **Site Settings**: Dynamic configuration management
- **Newsletter**: Email subscription management

### Real-time Features
- **Global Chat**: WebSocket-powered community chat with admin moderation
- **Live Updates**: Real-time cryptocurrency price tracking
- **Connection Management**: Heartbeat mechanism for connection reliability

## Data Flow

1. **User Registration/Login**: 
   - Traditional: Username/password → bcrypt hashing → session creation
   - Web3: Wallet connection → SIWE message generation → signature verification → session creation

2. **Airdrop Management**:
   - Content creation through rich editor → validation → database storage
   - Category-based organization → filtered retrieval → client-side display
   - View tracking and analytics collection

3. **Real-time Communication**:
   - WebSocket connection establishment → message broadcasting → client synchronization
   - Admin moderation capabilities → message filtering → user management

4. **File Management**:
   - Image upload → server-side processing → secure storage → URL generation
   - Profile image management → avatar system integration

## External Dependencies

### Cryptocurrency Data
- **CoinGecko API**: Live price feeds and market data
- **Caching Strategy**: 1-minute TTL to reduce API calls and improve performance

### Third-party Services
- **Replit Integration**: Development environment with cartographer plugin
- **PostgreSQL**: Primary database with connection pooling
- **Web3 Libraries**: SIWE for Ethereum wallet authentication

### Security Dependencies
- **bcrypt**: Password hashing with salt generation
- **express-session**: Secure session management
- **CORS**: Cross-origin resource sharing configuration
- **Input Validation**: Zod schemas for request validation

## Deployment Strategy

### Development Environment
- **Replit Configuration**: Automated setup with PostgreSQL module
- **Hot Reload**: Vite development server with HMR
- **Environment Variables**: Separate development and production configurations

### Production Deployment (One-Click VPS Setup)
- **Master Setup Script**: `setup-production.sh` - Complete automated VPS preparation
- **Application Deployment**: `deploy-app.sh` - Code deployment and build process
- **SSL Configuration**: `ssl-setup.sh` - Let's Encrypt SSL certificate automation
- **Health Monitoring**: `health-check.sh` - Comprehensive system health verification
- **Documentation**: `README-VPS-DEPLOYMENT.md` - Complete deployment guide

### VPS Infrastructure
- **Operating System**: Ubuntu 20.04+ or Debian 11+ support
- **Process Management**: PM2 with cluster mode and automatic restarts
- **Web Server**: Nginx reverse proxy with security headers and compression
- **Database**: PostgreSQL with optimized configuration and connection pooling
- **Security**: UFW firewall, secure file permissions, SSL/TLS encryption
- **Monitoring**: Automated health checks, resource monitoring, log analysis
- **Backup System**: Automated weekly database and application backups with cleanup
- **SSL Support**: Let's Encrypt with automatic renewal and HTTPS enforcement

### Automated Features
- **One-Command Setup**: Single script deploys entire production environment
- **Dependency Management**: Automatic installation of Node.js, PostgreSQL, Nginx, PM2
- **Configuration Management**: Environment variables, PM2 ecosystem, Nginx sites
- **Security Hardening**: Firewall setup, file permissions, SSL certificates
- **Monitoring Setup**: Health checks, backup scripts, log rotation
- **Error Recovery**: Automatic application restart, connection monitoring

## Changelog

- June 14, 2025: Initial project setup and architecture
- June 21, 2025: Streamlined Docker deployment system:
  - `docker-deploy.sh` - Single command deploys entire stack
  - `manage.sh` - Unified management script for all operations
  - `Dockerfile` & `docker-compose.yml` - Production container orchestration
  - `nginx.conf` - Reverse proxy with security and rate limiting
  - `README-DEPLOY.md` - Simplified deployment documentation
  - Eliminated old scripts and consolidated into clean Docker workflow
  - Fixed environment variable generation and sed command issues

## User Preferences

Preferred communication style: Simple, everyday language.