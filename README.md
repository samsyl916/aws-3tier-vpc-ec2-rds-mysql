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

## Build Steps (High Level)

1. VPC + Subnets (2 AZ)
  - Create 6 subnets: public/app/db across us-east-1a and us-east-1b
2. Internet + NAT
  - Attach IGW to VPC
  - Allocate EIP + create NAT Gateway in public-1a
  - Configure route tables: public→IGW, app→NAT, db→local
3. Security Groups
  - ALB SG / App SG / DB SG with SG-to-SG rules
4. RDS MySQL
  - Create DB Subnet Group using db-1a/db-1b
  - Create MySQL DB with Public access = No
5. EC2 App (Private)
  - Launch EC2 in app-1a (no public IP)
  - Install Nginx + Flask app
  - Nginx reverse proxy: :80 → 127.0.0.1:5000
6. ALB
  - Create target group (HTTP:80), register EC2
  - Create ALB in public subnets and forward :80 to the target group
7. SSM Validation (No-SSH)
  - Use SSM Session Manager to run commands and validate service/db connectivity

## Deliverables / Evidence
- docs/diagram: architecture diagram
- docs/screenshots: VPC, subnets, route tables, SG rules, ALB target health, RDS connectivity test
- userdata/: EC2 user-data bootstrap scripts
- notes/: design decisions and troubleshooting notes

## Cleanup (Cost Control)

To avoid ongoing charges, delete resources in roughly this order:
1. RDS database
2. ALB
3. Target Group
4. EC2 instance
5. NAT Gateway
6. Elastic IP (release)
7. Internet Gateway (detach + delete)
8. Route tables (custom ones)
9. Security groups
10. Subnets
11. VPC

Most expensive to forget: NAT Gateway + Elastic IP + ALB + RDS. 

## Skills Demonstrated
- VPC design (multi-AZ subnetting)
- Secure routing with IGW/NAT and isolated DB subnets
- Security Group layering (SG-to-SG)
- ALB target groups and load balancing
- Private EC2 operations via SSM (no SSH)
- RDS MySQL private connectivity from app tier
