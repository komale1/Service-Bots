# Decentralized Robotics Service Exchange Smart Contract

## Overview

The Decentralized Robotics Service Exchange is a comprehensive blockchain-based marketplace that enables seamless interaction between customers and autonomous robotics service providers. This platform revolutionizes the robotics service industry by providing decentralized booking management, trustless escrow payments, transparent reputation systems, and multi-category service offerings.

## Features

### Core Capabilities
- **Trustless Provider Registration**: Blockchain-verified credentials and provider profiles
- **Cross-Category Service Marketplace**: Real-time availability across multiple robotics service categories
- **Automated Escrow System**: Smart contract-based payment protection with dispute resolution
- **Bidirectional Reputation System**: Rating system for both providers and customers
- **Dynamic Booking Lifecycle**: Automated state transitions throughout the service process
- **Decentralized Governance**: Transparent fee distribution and platform management

### Service Categories
- **Household Cleaning Services** (Category: 100)
- **Logistics & Delivery Services** (Category: 200)
- **Security Monitoring Services** (Category: 300)
- **Facility Maintenance Services** (Category: 400)
- **Entertainment & Companion Services** (Category: 500)

## Architecture

### Core Components
1. **Provider Registration System**: Manages robotics service provider accounts
2. **Service Marketplace**: Handles service listings and availability
3. **Booking Management**: Processes customer bookings and service requests
4. **Escrow Payment System**: Secures payments until service completion
5. **Reputation System**: Tracks ratings and reviews for quality assurance

### Data Structures
- **Provider Registry**: Stores provider information, earnings, and ratings
- **Service Catalog**: Maintains available services with pricing and descriptions
- **Booking Records**: Tracks booking lifecycle and payment details
- **Escrow Accounts**: Manages locked payments during service execution

## Getting Started

### Prerequisites
- Stacks blockchain environment
- Clarity smart contract deployment capability
- STX tokens for transactions and service payments

### Deployment
1. Deploy the smart contract to the Stacks blockchain
2. The deployer becomes the contract administrator
3. Platform commission is set to 2.5% (250 basis points)

## Usage Guide

### For Service Providers

#### 1. Register as a Provider
```clarity
(register-robotics-service-provider "My Robot Services" "Professional cleaning and maintenance robots")
```

#### 2. Create Service Listings
```clarity
(create-service-marketplace-listing 
  "Home Cleaning Robot" 
  "Autonomous vacuum and mopping service for residential properties" 
  u100  ;; household-cleaning-services
  u50)  ;; 50 microSTX per hour
```

#### 3. Manage Bookings
- Accept customer bookings: `accept-customer-booking-request`
- Start service execution: `initiate-service-execution`
- Complete service: `finalize-service-completion`

#### 4. Update Profile and Services
```clarity
(update-provider-business-profile "Updated Name" "New Description" true)
(update-service-marketplace-listing service-id "New Title" "Updated Description" u60 true)
```

### For Customers

#### 1. Browse Available Services
Use read-only functions to explore services:
```clarity
(get-service-listing-information service-id)
(calculate-service-average-rating service-id)
```

#### 2. Book a Service
```clarity
(create-service-booking-request 
  u1001  ;; service-identifier
  u1000000  ;; preferred-start-block
  u3)  ;; duration in hours
```

#### 3. Cancel Booking (if needed)
```clarity
(cancel-booking-request booking-id)
```

#### 4. Rate Service Quality
```clarity
(submit-service-quality-rating booking-id u5 true)  ;; 5-star rating from customer
```

## Booking Lifecycle

### Status Flow
1. **Pending Provider Acceptance** (10): Customer creates booking, awaiting provider confirmation
2. **Confirmed by Provider** (20): Provider accepts the booking
3. **Service Execution Active** (30): Service is currently being performed
4. **Service Delivery Completed** (40): Service finished successfully
5. **Booking Cancelled** (50): Booking cancelled by either party
6. **Dispute Resolution Pending** (60): Dispute resolution in progress

### Payment Flow
1. Customer payment escrowed when booking is created
2. Payment held securely during service execution
3. Upon completion, provider receives payment minus platform fee
4. Platform fee (2.5%) retained by contract
5. Refund issued if booking is cancelled before service starts

## API Reference

### Provider Functions
- `register-robotics-service-provider`: Register as a new provider
- `update-provider-business-profile`: Update provider information
- `create-service-marketplace-listing`: Create new service listing
- `update-service-marketplace-listing`: Modify existing service
- `accept-customer-booking-request`: Accept a customer booking
- `initiate-service-execution`: Start service execution
- `finalize-service-completion`: Complete service and receive payment

### Customer Functions
- `create-service-booking-request`: Book a service
- `cancel-booking-request`: Cancel a booking
- `submit-service-quality-rating`: Rate service quality

### Query Functions
- `get-provider-account-information`: Get provider details
- `get-service-listing-information`: Get service information
- `get-booking-record-information`: Get booking details
- `calculate-provider-average-rating`: Get provider's average rating
- `calculate-service-average-rating`: Get service's average rating
- `get-platform-revenue-balance`: Get total platform revenue
- `get-booking-escrow-balance`: Get escrowed amount for booking
- `verify-provider-registration-status`: Check if provider is registered

### Admin Functions
- `withdraw-accumulated-platform-revenue`: Withdraw platform fees (admin only)

## Error Codes

| Code | Description |
|------|-------------|
| 4000 | Invalid Parameters |
| 4001 | Unauthorized Operation |
| 4002 | Provider Already Registered |
| 4003 | Insufficient Balance |
| 4004 | Resource Not Found |
| 4005 | Service Not Available |
| 4006 | Booking Not Active |
| 4007 | Invalid Status Transition |
| 4008 | Operation Already Executed |
| 4009 | Rating Value Out of Range |

## Security Features

### Payment Security
- Escrow system protects customer payments
- Funds only released upon service completion
- Automatic refunds for cancelled bookings

### Access Control
- Provider-only functions restricted to registered providers
- Customer-only functions restricted to booking creators
- Admin functions restricted to contract administrator

### Data Validation
- Input validation for all parameters
- String length and content validation
- Numeric range validation for ratings and amounts

## Economics

### Platform Fees
- **Commission Rate**: 2.5% of total booking value
- **Fee Distribution**: Retained by platform for operational costs
- **Provider Earnings**: 97.5% of booking value after successful completion

### Rating System
- **Scale**: 1-5 stars for service quality
- **Bilateral**: Both customers and providers can rate each other
- **Aggregated**: Average ratings calculated automatically
- **Transparent**: All ratings stored on-chain

## Best Practices

### For Providers
1. Maintain accurate service descriptions and pricing
2. Respond promptly to booking requests
3. Provide excellent service to maintain high ratings
4. Keep service availability updated
5. Complete services on time to ensure payment release

### For Customers
1. Review provider ratings before booking
2. Provide accurate service requirements
3. Be present during scheduled service time
4. Rate services fairly to maintain ecosystem integrity
5. Cancel bookings promptly if plans change