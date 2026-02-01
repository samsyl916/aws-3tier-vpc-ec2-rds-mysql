#!/bin/bash
dnf update -y
dnf install -y nginx
cat > /usr/share/nginx/html/index.html <<'EOF'
<h1>proj1 app layer - healthy</h1>
EOF
systemctl enable nginx
systemctl start nginx
