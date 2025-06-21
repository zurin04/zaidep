#!/bin/bash

# One-Click Docker Deployment for Crypto Airdrop Platform
# Usage: sudo ./docker-deploy.sh [domain]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOMAIN="$1"

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Function to check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Function to detect OS
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        print_error "Cannot detect OS. This script supports Ubuntu 20.04+ and Debian 11+"
        exit 1
    fi
    
    if [[ "$OS" != "ubuntu" && "$OS" != "debian" ]]; then
        print_error "Unsupported OS: $OS. This script supports Ubuntu 20.04+ and Debian 11+"
        exit 1
    fi
    
    print_success "Detected OS: $OS $VERSION"
}

# Function to update system
update_system() {
    print_status "Updating system packages..."
    apt update -y
    apt upgrade -y
    apt install -y curl wget git unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release ufw
    print_success "System updated"
}

# Function to install Docker
install_docker() {
    print_status "Installing Docker..."
    
    # Remove any old Docker installations
    apt remove -y docker docker-engine docker.io containerd runc || true
    
    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # Verify installation
    docker --version
    docker-compose --version
    
    print_success "Docker and Docker Compose installed"
}

# Function to setup firewall
setup_firewall() {
    print_status "Configuring firewall..."
    
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    
    print_success "Firewall configured"
}

# Function to generate secure passwords
generate_secrets() {
    print_status "Generating secure environment variables..."
    
    # Create .env file from template
    cp .env.docker .env
    
    # Generate secure passwords (alphanumeric only to avoid sed issues)
    DB_PASSWORD=$(openssl rand -hex 16)
    SESSION_SECRET=$(openssl rand -hex 32)
    
    # Update .env file with safe sed replacement
    sed -i "s|crypto_secure_password_2024_change_this|$DB_PASSWORD|g" .env
    sed -i "s|crypto_session_secret_2024_change_this_to_something_secure|$SESSION_SECRET|g" .env
    
    if [[ -n "$DOMAIN" ]]; then
        sed -i "s/DOMAIN=/DOMAIN=$DOMAIN/" .env
    fi
    
    # Secure the .env file
    chmod 600 .env
    
    print_success "Environment variables configured"
}

# Function to setup SSL (if domain provided)
setup_ssl() {
    if [[ -n "$DOMAIN" ]]; then
        print_status "Setting up SSL for domain: $DOMAIN"
        
        # Create SSL directory
        mkdir -p ssl
        
        # Install Certbot
        snap install core; snap refresh core
        snap install --classic certbot
        ln -sf /snap/bin/certbot /usr/bin/certbot
        
        # Stop any running nginx
        docker-compose down nginx || true
        
        # Obtain SSL certificate
        certbot certonly --standalone -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN
        
        # Copy certificates to ssl directory
        cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem ssl/cert.pem
        cp /etc/letsencrypt/live/$DOMAIN/privkey.pem ssl/key.pem
        
        # Set proper permissions
        chmod 644 ssl/cert.pem
        chmod 600 ssl/key.pem
        
        print_success "SSL certificates configured"
    else
        print_warning "No domain provided - SSL setup skipped"
        # Create empty SSL directory to prevent nginx errors
        mkdir -p ssl
        touch ssl/.keep
    fi
}

# Function to build and start application
deploy_application() {
    print_status "Building and starting application..."
    
    # Build and start services
    docker-compose build --no-cache
    docker-compose up -d
    
    # Wait for services to be ready
    print_status "Waiting for services to start..."
    sleep 30
    
    # Check if services are running
    if docker-compose ps | grep -q "Up"; then
        print_success "Services started successfully"
    else
        print_error "Some services failed to start"
        docker-compose logs
        exit 1
    fi
    
    # Setup database schema
    print_status "Setting up database schema..."
    docker-compose exec -T app npm run db:push
    
    print_success "Application deployed successfully"
}

# Function to create management commands
create_management_commands() {
    print_status "Creating management commands..."
    
    cat > manage.sh << 'EOF'
#!/bin/bash
# Crypto Airdrop Platform Management Script

case "$1" in
    logs)
        echo "Application logs (Ctrl+C to exit):"
        docker-compose logs -f app
        ;;
    status)
        echo "=== Services Status ==="
        docker-compose ps
        echo ""
        echo "=== Resource Usage ==="
        docker stats --no-stream
        ;;
    backup)
        BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
        echo "Creating backup: $BACKUP_FILE"
        docker-compose exec -T postgres pg_dump -U crypto_user crypto_airdrop_db > $BACKUP_FILE
        echo "Backup completed: $BACKUP_FILE"
        ;;
    update)
        echo "Updating application..."
        docker-compose pull && docker-compose build --no-cache && docker-compose up -d
        echo "Update completed!"
        ;;
    restart)
        docker-compose restart
        ;;
    stop)
        docker-compose down
        ;;
    start)
        docker-compose up -d
        ;;
    *)
        echo "Usage: $0 {logs|status|backup|update|restart|stop|start}"
        echo ""
        echo "Commands:"
        echo "  logs    - View application logs"
        echo "  status  - Show services status and resource usage"
        echo "  backup  - Create database backup"
        echo "  update  - Update and restart application"
        echo "  restart - Restart all services"
        echo "  stop    - Stop all services"
        echo "  start   - Start all services"
        exit 1
        ;;
esac
EOF
    
    chmod +x manage.sh
    print_success "Management script created"
}

# Function to display final information
display_success() {
    local server_ip=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")
    
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                       DOCKER DEPLOYMENT SUCCESSFUL!                         ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}🚀 Your Crypto Airdrop Platform is now live!${NC}"
    echo ""
    
    if [[ -n "$DOMAIN" ]]; then
        echo -e "${BLUE}Access your application:${NC}"
        echo "• HTTPS URL: https://$DOMAIN"
        echo "• HTTP URL: http://$DOMAIN (redirects to HTTPS)"
    else
        echo -e "${BLUE}Access your application:${NC}"
        echo "• HTTP URL: http://$server_ip"
    fi
    
    echo ""
    echo -e "${BLUE}Docker Services:${NC}"
    docker-compose ps
    
    echo ""
    echo -e "${BLUE}Management Commands:${NC}"
    echo "• View logs: ./manage.sh logs"
    echo "• Check status: ./manage.sh status"
    echo "• Update app: ./manage.sh update"
    echo "• Backup database: ./manage.sh backup"
    echo "• Restart: ./manage.sh restart"
    echo "• Stop: ./manage.sh stop"
    
    echo ""
    echo -e "${BLUE}Useful Docker Commands:${NC}"
    echo "• View all logs: docker-compose logs -f"
    echo "• View app logs: docker-compose logs -f app"
    echo "• View db logs: docker-compose logs -f postgres"
    echo "• Execute commands in app: docker-compose exec app <command>"
    echo "• Connect to database: docker-compose exec postgres psql -U crypto_user crypto_airdrop_db"
    
    echo ""
    echo -e "${BLUE}Important Files:${NC}"
    echo "• Configuration: docker-compose.yml"
    echo "• Environment: .env"
    echo "• SSL Certificates: ssl/"
    echo "• Application logs: docker-compose logs app"
    
    if [[ -n "$DOMAIN" ]]; then
        echo ""
        echo -e "${YELLOW}SSL Certificate Auto-Renewal:${NC}"
        echo "• Certificates will be renewed automatically"
        echo "• Manual renewal: certbot renew"
    fi
    
    echo ""
    echo -e "${GREEN}✅ Deployment complete! Your crypto airdrop platform is running in Docker containers.${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    Docker VPS Deployment for Crypto Airdrop                 ║${NC}"
    echo -e "${BLUE}║                              One-Click Setup                                ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ -n "$DOMAIN" ]]; then
        print_status "Deploying with domain: $DOMAIN"
    else
        print_status "Deploying with IP-based access"
    fi
    
    detect_os
    check_root
    
    print_status "Starting Docker deployment process..."
    
    # Installation steps
    update_system
    install_docker
    setup_firewall
    generate_secrets
    setup_ssl
    deploy_application
    create_management_commands
    
    display_success
}

# Error handling
trap 'print_error "Deployment failed. Check the logs above for details."' ERR

# Run main function
main "$@"