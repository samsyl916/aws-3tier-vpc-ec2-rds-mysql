# AWS 3-Tier Architecture (VPC + ALB + EC2 + RDS MySQL)

## Overview
This project deploys a secure 3-tier architecture on AWS:
- Public layer: Application Load Balancer (ALB)
- Private app layer: EC2 (web/app) in private subnets
- Private data layer: Amazon RDS MySQL in isolated DB subnets

Goal: demonstrate production-style networking, security controls, and private database connectivity for junior Cloud Engineer roles in Hong Kong.

## Architecture
- VPC CIDR: 10.0.0.0/16
- 2 AZs
- Public subnets (x2): ALB + NAT Gateway
- Private app subnets (x2): EC2 instances
- Private DB subnets (x2): RDS MySQL
- Internet Gateway for public ingress
- NAT Gateway for outbound patching from private subnets

## Security Design
- ALB SG: allow 80/443 from Internet
- App SG: allow 80 from ALB SG only
- DB SG: allow 3306 from App SG only
- No public IP on EC2 / RDS
- RDS is not publicly accessible

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
