#!/bin/bash

# Quick VPS deployment test script
# Run this on your VPS to test the deployment

set -e

echo "=== VPS Deployment Quick Test ==="
echo "Server: $(hostname)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"')"
echo "Date: $(date)"
echo ""

# Test 1: Download scripts
echo "1. Testing script download..."
if curl -fsSL https://raw.githubusercontent.com/yourusername/crypto-airdrop/main/setup-production.sh -o /tmp/setup-test.sh; then
    echo "✓ Script download works"
    rm -f /tmp/setup-test.sh
else
    echo "✗ Script download failed - update GitHub URL"
fi

# Test 2: Check system requirements
echo ""
echo "2. Checking system requirements..."

# Check OS
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$NAME" == *"Ubuntu"* ]] || [[ "$NAME" == *"Debian"* ]]; then
        echo "✓ Supported OS: $NAME $VERSION_ID"
    else
        echo "⚠ OS might not be supported: $NAME $VERSION_ID"
    fi
else
    echo "✗ Cannot detect OS"
fi

# Check memory
memory_gb=$(free -g | grep Mem | awk '{print $2}')
if [[ $memory_gb -ge 1 ]]; then
    echo "✓ Memory: ${memory_gb}GB (sufficient)"
else
    echo "⚠ Memory: ${memory_gb}GB (might be low)"
fi

# Check disk space
disk_free=$(df / | tail -1 | awk '{print $4}')
disk_free_gb=$((disk_free / 1024 / 1024))
if [[ $disk_free_gb -ge 5 ]]; then
    echo "✓ Disk space: ${disk_free_gb}GB free (sufficient)"
else
    echo "⚠ Disk space: ${disk_free_gb}GB free (might be low)"
fi

# Test 3: Check required commands
echo ""
echo "3. Checking required commands..."
commands=("curl" "wget" "systemctl" "apt-get")
for cmd in "${commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✓ $cmd available"
    else
        echo "✗ $cmd missing"
    fi
done

# Test 4: Check network connectivity
echo ""
echo "4. Testing network connectivity..."
if curl -s --connect-timeout 5 http://www.google.com >/dev/null; then
    echo "✓ Internet connectivity working"
else
    echo "✗ Internet connectivity failed"
fi

# Test 5: Check sudo access
echo ""
echo "5. Checking privileges..."
if [[ $EUID -eq 0 ]]; then
    echo "✓ Running as root"
elif sudo -n true 2>/dev/null; then
    echo "✓ Sudo access available"
else
    echo "✗ Need root or sudo access"
fi

echo ""
echo "=== Test Complete ==="
echo "If all checks pass, you can proceed with:"
echo "curl -fsSL https://raw.githubusercontent.com/yourusername/crypto-airdrop/main/setup-production.sh | sudo bash"