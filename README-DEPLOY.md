# 🚀 Docker VPS Deployment

Deploy your Crypto Airdrop Platform to any VPS with one command using Docker.

## Quick Deploy

```bash
# Upload files to VPS
scp -r . root@your-vps-ip:~/crypto-airdrop/

# SSH and deploy
ssh root@your-vps-ip
cd ~/crypto-airdrop

# Deploy (choose one)
sudo ./docker-deploy.sh                    # HTTP only
sudo ./docker-deploy.sh your-domain.com    # HTTPS with SSL
```

## What Gets Deployed

- **PostgreSQL Database** - Persistent data storage
- **Node.js Application** - Your crypto airdrop platform
- **Nginx Reverse Proxy** - Web server with security headers
- **SSL Certificates** - Let's Encrypt (if domain provided)
- **Firewall & Security** - UFW configured automatically

## Management

After deployment, use the management script:

```bash
./manage.sh logs      # View application logs
./manage.sh status    # Check services and resources
./manage.sh backup    # Create database backup
./manage.sh update    # Update application
./manage.sh restart   # Restart services
./manage.sh stop      # Stop all services
./manage.sh start     # Start all services
```

## Direct Docker Commands

```bash
# View services
docker-compose ps

# View logs
docker-compose logs -f app

# Restart specific service
docker-compose restart app

# Connect to database
docker-compose exec postgres psql -U crypto_user crypto_airdrop_db

# Execute commands in app container
docker-compose exec app npm run db:seed
```

## Environment Variables

Automatically generated secure configuration:
- Database password (32-character hex)
- Session secret (64-character hex)
- Production environment settings

## VPS Requirements

**Minimum:**
- Ubuntu 20.04+ or Debian 11+
- 2GB RAM, 20GB storage
- Public IP address

**Supported Providers:**
- DigitalOcean, Linode, Vultr
- AWS EC2, Google Cloud, Azure
- Any Ubuntu/Debian VPS

## Troubleshooting

**Services won't start:**
```bash
docker-compose ps
docker-compose logs app
docker-compose restart
```

**Database issues:**
```bash
docker-compose exec postgres pg_isready
docker-compose restart postgres
```

**Application not responding:**
```bash
curl http://localhost
docker-compose logs -f app
```

**Reset everything:**
```bash
docker-compose down
docker system prune -a
sudo ./docker-deploy.sh
```

## SSL Setup

**Automatic with domain:**
```bash
sudo ./docker-deploy.sh your-domain.com
```

**Manual SSL later:**
```bash
sudo certbot certonly --standalone -d your-domain.com
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ssl/key.pem
docker-compose restart nginx
```

## Backup & Restore

**Create backup:**
```bash
./manage.sh backup
```

**Restore from backup:**
```bash
docker-compose exec -T postgres psql -U crypto_user crypto_airdrop_db < backup.sql
```

## Benefits of Docker Deployment

✅ **Consistent Environment** - Same setup everywhere  
✅ **No Dependency Issues** - Isolated containers  
✅ **Easy Updates** - One command updates  
✅ **Automatic Recovery** - Health checks and restarts  
✅ **Secure by Default** - Container isolation  
✅ **Production Ready** - Optimized configuration  

Your crypto airdrop platform will be live and stable within minutes of deployment.