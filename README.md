# AWS 3-Tier Architecture (VPC + ALB + EC2 + RDS MySQL)

## Overview
This project deploys a secure and production-style 3-tier architecture on AWS:
- Public layer: Application Load Balancer (ALB) in public subnets (multi-AZ)
- App layer: EC2 (private subnets) running a simple Flask API behind Nginx
- Private data layer: Amazon RDS MySQL in isolated DB subnets
- Operations: AWS Systems Manager (SSM) Session Manager for instance access (no SSH / no bastion)

Goal: demonstrate production-style networking, security controls, and private database connectivity for junior Cloud Engineer roles.

## Architecture
Flow:
Internet → ALB (public) → EC2 App (private) → RDS MySQL (private)

Network layout (2 AZ):

- Public: public-1a, public-1b
- Private App: app-1a, app-1b
- Private DB: db-1a, db-1b

## Key Design Choices
Security Groups (least privilege)
- ALB SG
  - Inbound: 80 from 0.0.0.0/0
  - Outbound: allow all (demo)

- App SG
  - Inbound: 80 from ALB SG
  - Outbound: allow all (demo)

- DB SG
  - Inbound: 3306 from App SG
  - Outbound: allow all (demo)

Routing
- Public Route Table: 0.0.0.0/0 → IGW (for ALB / NAT)
- App Route Table: 0.0.0.0/0 → NAT Gateway (for package updates)
- DB Route Table: local only (no internet route)

Operations (No-SSH)
- Used SSM Session Manager to access the private EC2 instance
- Port 22 not opened; no bastion host required

## API Endpoints
Assuming the ALB DNS name is http://<ALB-DNS>:
- GET / → returns OK
- GET /db → connects to MySQL and returns {"result": 1}

## Deliverables / Evidence
- docs/diagram: architecture diagram
- docs/screenshots: VPC, subnets, route tables, SG rules, ALB target health, RDS connectivity test, CloudWatch metrics/logs
- userdata/: EC2 user-data bootstrap scripts
- notes/: design decisions and troubleshooting notes

## How to Deploy (High Level)
1. Create VPC with 2 AZs and subnets (public/app/db)
2. Create route tables + IGW + NAT
3. Create Security Groups (ALB/App/DB)
4. Launch ALB in public subnets
5. Launch EC2 in private app subnets (with user data)
6. Create RDS MySQL in DB subnets (private)
7. Validate: EC2 can connect to RDS over private networking

## Validation
- Confirm ALB -> EC2 (HTTP 200)
- Confirm EC2 -> RDS (mysql client connection)
- Confirm DB is not reachable from the Internet
