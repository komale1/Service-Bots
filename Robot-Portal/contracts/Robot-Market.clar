;; DECENTRALIZED ROBOTICS SERVICE EXCHANGE SMART CONTRACT
;; 
;; A comprehensive blockchain-based marketplace that enables seamless interaction between
;; customers and autonomous robotics service providers. This platform revolutionizes
;; the robotics service industry by providing decentralized booking management, 
;; trustless escrow payments, transparent reputation systems, and multi-category
;; service offerings spanning household automation, industrial logistics, security
;; monitoring, infrastructure maintenance, and interactive entertainment robotics.
;;
;; Platform Capabilities:
;; - Trustless provider registration with blockchain-verified credentials
;; - Cross-category robotics service marketplace with real-time availability
;; - Automated escrow payment system with smart contract dispute resolution
;; - Bidirectional reputation scoring for providers and customers
;; - Dynamic booking lifecycle with automated state transitions
;; - Decentralized governance with transparent fee distribution

;; ERROR CODES AND VALIDATION

(define-constant ERR-INVALID-PARAMETERS (err u4000))
(define-constant ERR-UNAUTHORIZED-OPERATION (err u4001))
(define-constant ERR-PROVIDER-ALREADY-REGISTERED (err u4002))
(define-constant ERR-INSUFFICIENT-BALANCE (err u4003))
(define-constant ERR-RESOURCE-NOT-FOUND (err u4004))
(define-constant ERR-SERVICE-NOT-AVAILABLE (err u4005))
(define-constant ERR-BOOKING-NOT-ACTIVE (err u4006))
(define-constant ERR-INVALID-STATUS-TRANSITION (err u4007))
(define-constant ERR-OPERATION-ALREADY-EXECUTED (err u4008))
(define-constant ERR-RATING-VALUE-OUT-OF-RANGE (err u4009))

;; PLATFORM CONFIGURATION

(define-constant contract-administrator tx-sender)
(define-constant platform-commission-basis-points u250) ;; 2.5% marketplace fee

;; SERVICE CATEGORY DEFINITIONS

(define-constant household-cleaning-services u100)
(define-constant logistics-delivery-services u200)
(define-constant security-monitoring-services u300)
(define-constant facility-maintenance-services u400)
(define-constant entertainment-companion-services u500)

;; BOOKING STATUS DEFINITIONS

(define-constant pending-provider-acceptance u10)
(define-constant confirmed-by-provider u20)
(define-constant service-execution-active u30)
(define-constant service-delivery-completed u40)
(define-constant booking-cancelled-by-party u50)
(define-constant dispute-resolution-pending u60)

;; GLOBAL STATE VARIABLES

(define-data-var current-service-identifier uint u1000)
(define-data-var current-booking-identifier uint u2000)
(define-data-var accumulated-platform-revenue uint u0)

;; CORE DATA STRUCTURES

;; Autonomous Robotics Service Provider Registry
(define-map registered-robotics-providers
  principal
  {
    provider-display-name: (string-ascii 50),
    comprehensive-service-description: (string-ascii 200),
    account-active-status: bool,
    cumulative-earnings-ustx: uint,
    total-services-offered: uint,
    aggregated-rating-points: uint,
    total-rating-submissions: uint,
    blockchain-registration-height: uint
  }
)

;; Marketplace Service Catalog Registry
(define-map available-robotics-services
  uint
  {
    service-provider-address: principal,
    service-listing-title: (string-ascii 100),
    detailed-service-description: (string-ascii 300),
    service-category-classification: uint,
    hourly-service-rate-ustx: uint,
    current-availability-status: bool,
    listing-creation-height: uint,
    total-successful-bookings: uint,
    service-rating-points-sum: uint,
    service-rating-count: uint
  }
)

;; Customer Service Booking Registry
(define-map customer-booking-records
  uint
  {
    referenced-service-identifier: uint,
    booking-customer-address: principal,
    assigned-provider-address: principal,
    scheduled-start-block: uint,
    requested-duration-hours: uint,
    total-booking-cost-ustx: uint,
    calculated-platform-fee-ustx: uint,
    booking-lifecycle-status: uint,
    booking-creation-height: uint,
    service-completion-height: (optional uint),
    customer-submitted-rating: (optional uint),
    provider-submitted-rating: (optional uint)
  }
)

;; Escrow Payment Management System
(define-map booking-payment-escrow
  uint  ;; booking-identifier
  uint  ;; escrowed-payment-amount-ustx
)

;; Provider Service Count Tracking
(define-map provider-active-service-count
  principal
  uint
)

;; INTERNAL UTILITY FUNCTIONS

(define-private (verify-contract-administrator)
  (is-eq tx-sender contract-administrator)
)

(define-private (compute-platform-commission (total-payment-ustx uint))
  (/ (* total-payment-ustx platform-commission-basis-points) u10000)
)

(define-private (increment-service-identifier)
  (let ((next-identifier (var-get current-service-identifier)))
    (var-set current-service-identifier (+ next-identifier u1))
    next-identifier
  )
)

(define-private (increment-booking-identifier)
  (let ((next-identifier (var-get current-booking-identifier)))
    (var-set current-booking-identifier (+ next-identifier u1))
    next-identifier
  )
)

(define-private (validate-service-category (category-code uint))
  (or (is-eq category-code household-cleaning-services)
      (is-eq category-code logistics-delivery-services)
      (is-eq category-code security-monitoring-services)
      (is-eq category-code facility-maintenance-services)
      (is-eq category-code entertainment-companion-services))
)

(define-private (validate-rating-score (rating-value uint))
  (and (>= rating-value u1) (<= rating-value u5))
)

(define-private (validate-string-not-empty (input-string (string-ascii 300)))
  (> (len input-string) u0)
)

;; PROVIDER REGISTRATION SYSTEM

(define-public (register-robotics-service-provider 
  (provider-business-name (string-ascii 50)) 
  (business-description (string-ascii 200)))
  (let ((registering-provider-address tx-sender))
    (asserts! (is-none (map-get? registered-robotics-providers registering-provider-address)) 
              ERR-PROVIDER-ALREADY-REGISTERED)
    (asserts! (validate-string-not-empty provider-business-name) ERR-INVALID-PARAMETERS)
    (asserts! (validate-string-not-empty business-description) ERR-INVALID-PARAMETERS)
    
    (ok (map-set registered-robotics-providers registering-provider-address {
      provider-display-name: provider-business-name,
      comprehensive-service-description: business-description,
      account-active-status: true,
      cumulative-earnings-ustx: u0,
      total-services-offered: u0,
      aggregated-rating-points: u0,
      total-rating-submissions: u0,
      blockchain-registration-height: block-height
    }))
  )
)

(define-public (update-provider-business-profile 
  (updated-business-name (string-ascii 50)) 
  (updated-business-description (string-ascii 200)) 
  (account-activation-status bool))
  (let ((existing-provider-data (unwrap! (map-get? registered-robotics-providers tx-sender) 
                                        ERR-RESOURCE-NOT-FOUND)))
    (asserts! (validate-string-not-empty updated-business-name) ERR-INVALID-PARAMETERS)
    (asserts! (validate-string-not-empty updated-business-description) ERR-INVALID-PARAMETERS)
    
    (ok (map-set registered-robotics-providers tx-sender 
                 (merge existing-provider-data {
                   provider-display-name: updated-business-name,
                   comprehensive-service-description: updated-business-description,
                   account-active-status: account-activation-status
                 })))
  )
)

;; SERVICE MARKETPLACE MANAGEMENT

(define-public (create-service-marketplace-listing 
  (service-listing-title (string-ascii 100)) 
  (service-comprehensive-description (string-ascii 300)) 
  (service-category-type uint) 
  (hourly-rate-microstack uint))
  (let (
    (new-service-identifier (increment-service-identifier))
    (listing-provider-address tx-sender)
    (provider-account-data (unwrap! (map-get? registered-robotics-providers listing-provider-address) 
                           ERR-RESOURCE-NOT-FOUND))
    (provider-current-service-count (default-to u0 (map-get? provider-active-service-count listing-provider-address)))
  )
    (asserts! (get account-active-status provider-account-data) ERR-UNAUTHORIZED-OPERATION)
    (asserts! (validate-string-not-empty service-listing-title) ERR-INVALID-PARAMETERS)
    (asserts! (validate-string-not-empty service-comprehensive-description) ERR-INVALID-PARAMETERS)
    (asserts! (> hourly-rate-microstack u0) ERR-INVALID-PARAMETERS)
    (asserts! (validate-service-category service-category-type) ERR-INVALID-PARAMETERS)
    
    ;; Create marketplace service listing
    (map-set available-robotics-services new-service-identifier {
      service-provider-address: listing-provider-address,
      service-listing-title: service-listing-title,
      detailed-service-description: service-comprehensive-description,
      service-category-classification: service-category-type,
      hourly-service-rate-ustx: hourly-rate-microstack,
      current-availability-status: true,
      listing-creation-height: block-height,
      total-successful-bookings: u0,
      service-rating-points-sum: u0,
      service-rating-count: u0
    })
    
    ;; Update provider service statistics
    (map-set provider-active-service-count listing-provider-address (+ provider-current-service-count u1))
    
    (map-set registered-robotics-providers listing-provider-address 
             (merge provider-account-data {
               total-services-offered: (+ (get total-services-offered provider-account-data) u1)
             }))
    
    (ok new-service-identifier)
  )
)

(define-public (update-service-marketplace-listing 
  (service-identifier uint) 
  (updated-service-title (string-ascii 100)) 
  (updated-service-description (string-ascii 300)) 
  (updated-hourly-rate-ustx uint) 
  (service-availability-flag bool))
  (let ((existing-service-data (unwrap! (map-get? available-robotics-services service-identifier) 
                              ERR-RESOURCE-NOT-FOUND)))
    (asserts! (is-eq (get service-provider-address existing-service-data) tx-sender) 
              ERR-UNAUTHORIZED-OPERATION)
    (asserts! (validate-string-not-empty updated-service-title) ERR-INVALID-PARAMETERS)
    (asserts! (validate-string-not-empty updated-service-description) ERR-INVALID-PARAMETERS)
    (asserts! (> updated-hourly-rate-ustx u0) ERR-INVALID-PARAMETERS)
    
    (ok (map-set available-robotics-services service-identifier 
                 (merge existing-service-data {
                   service-listing-title: updated-service-title,
                   detailed-service-description: updated-service-description,
                   hourly-service-rate-ustx: updated-hourly-rate-ustx,
                   current-availability-status: service-availability-flag
                 })))
  )
)

;; CUSTOMER BOOKING SYSTEM

(define-public (create-service-booking-request 
  (requested-service-identifier uint) 
  (preferred-service-start-block uint) 
  (requested-service-duration-hours uint))
  (let (
    (selected-service-data (unwrap! (map-get? available-robotics-services requested-service-identifier) 
                          ERR-RESOURCE-NOT-FOUND))
    (new-booking-identifier (increment-booking-identifier))
    (booking-customer-address tx-sender)
    (assigned-provider-address (get service-provider-address selected-service-data))
    (calculated-total-cost-ustx (* (get hourly-service-rate-ustx selected-service-data) requested-service-duration-hours))
    (calculated-platform-fee-ustx (compute-platform-commission calculated-total-cost-ustx))
  )
    (asserts! (get current-availability-status selected-service-data) ERR-SERVICE-NOT-AVAILABLE)
    (asserts! (not (is-eq booking-customer-address assigned-provider-address)) ERR-UNAUTHORIZED-OPERATION)
    (asserts! (> requested-service-duration-hours u0) ERR-INVALID-PARAMETERS)
    (asserts! (> preferred-service-start-block block-height) ERR-INVALID-PARAMETERS)
    
    ;; Transfer customer payment to contract escrow
    (try! (stx-transfer? calculated-total-cost-ustx booking-customer-address (as-contract tx-sender)))
    
    ;; Create customer booking record
    (map-set customer-booking-records new-booking-identifier {
      referenced-service-identifier: requested-service-identifier,
      booking-customer-address: booking-customer-address,
      assigned-provider-address: assigned-provider-address,
      scheduled-start-block: preferred-service-start-block,
      requested-duration-hours: requested-service-duration-hours,
      total-booking-cost-ustx: calculated-total-cost-ustx,
      calculated-platform-fee-ustx: calculated-platform-fee-ustx,
      booking-lifecycle-status: pending-provider-acceptance,
      booking-creation-height: block-height,
      service-completion-height: none,
      customer-submitted-rating: none,
      provider-submitted-rating: none
    })
    
    ;; Establish escrow payment account
    (map-set booking-payment-escrow new-booking-identifier calculated-total-cost-ustx)
    
    ;; Update service booking statistics
    (map-set available-robotics-services requested-service-identifier 
             (merge selected-service-data {
               total-successful-bookings: (+ (get total-successful-bookings selected-service-data) u1)
             }))
    
    (ok new-booking-identifier)
  )
)

(define-public (accept-customer-booking-request (booking-identifier uint))
  (let ((booking-record-data (unwrap! (map-get? customer-booking-records booking-identifier) 
                              ERR-RESOURCE-NOT-FOUND)))
    (asserts! (is-eq (get assigned-provider-address booking-record-data) tx-sender) ERR-UNAUTHORIZED-OPERATION)
    (asserts! (is-eq (get booking-lifecycle-status booking-record-data) pending-provider-acceptance) 
              ERR-INVALID-STATUS-TRANSITION)
    
    (ok (map-set customer-booking-records booking-identifier 
                 (merge booking-record-data {
                   booking-lifecycle-status: confirmed-by-provider
                 })))
  )
)

(define-public (initiate-service-execution (booking-identifier uint))
  (let ((booking-record-data (unwrap! (map-get? customer-booking-records booking-identifier) 
                              ERR-RESOURCE-NOT-FOUND)))
    (asserts! (is-eq (get assigned-provider-address booking-record-data) tx-sender) ERR-UNAUTHORIZED-OPERATION)
    (asserts! (is-eq (get booking-lifecycle-status booking-record-data) confirmed-by-provider) 
              ERR-INVALID-STATUS-TRANSITION)
    (asserts! (>= block-height (get scheduled-start-block booking-record-data)) ERR-UNAUTHORIZED-OPERATION)
    
    (ok (map-set customer-booking-records booking-identifier 
                 (merge booking-record-data {
                   booking-lifecycle-status: service-execution-active
                 })))
  )
)

(define-public (finalize-service-completion (booking-identifier uint))
  (let (
    (booking-record-data (unwrap! (map-get? customer-booking-records booking-identifier) 
                          ERR-RESOURCE-NOT-FOUND))
    (escrowed-payment-amount (unwrap! (map-get? booking-payment-escrow booking-identifier) 
                           ERR-RESOURCE-NOT-FOUND))
    (service-provider-address (get assigned-provider-address booking-record-data))
    (platform-commission-fee (get calculated-platform-fee-ustx booking-record-data))
    (provider-net-payment (- escrowed-payment-amount platform-commission-fee))
    (provider-account-data (unwrap! (map-get? registered-robotics-providers service-provider-address) 
                           ERR-RESOURCE-NOT-FOUND))
  )
    (asserts! (is-eq service-provider-address tx-sender) ERR-UNAUTHORIZED-OPERATION)
    (asserts! (is-eq (get booking-lifecycle-status booking-record-data) service-execution-active) 
              ERR-INVALID-STATUS-TRANSITION)
    
    ;; Transfer net payment to service provider
    (try! (as-contract (stx-transfer? provider-net-payment tx-sender service-provider-address)))
    
    ;; Accumulate platform commission revenue
    (var-set accumulated-platform-revenue 
             (+ (var-get accumulated-platform-revenue) platform-commission-fee))
    
    ;; Update booking completion status
    (map-set customer-booking-records booking-identifier 
             (merge booking-record-data {
               booking-lifecycle-status: service-delivery-completed,
               service-completion-height: (some block-height)
             }))
    
    ;; Clear escrow payment account
    (map-delete booking-payment-escrow booking-identifier)
    
    ;; Update provider earnings record
    (map-set registered-robotics-providers service-provider-address 
             (merge provider-account-data {
               cumulative-earnings-ustx: (+ (get cumulative-earnings-ustx provider-account-data) provider-net-payment)
             }))
    
    (ok true)
  )
)

(define-public (cancel-booking-request (booking-identifier uint))
  (let (
    (booking-record-data (unwrap! (map-get? customer-booking-records booking-identifier) 
                          ERR-RESOURCE-NOT-FOUND))
    (cancellation-requester-address tx-sender)
    (booking-customer-address (get booking-customer-address booking-record-data))
    (assigned-provider-address (get assigned-provider-address booking-record-data))
    (current-booking-status (get booking-lifecycle-status booking-record-data))
    (escrowed-refund-amount (unwrap! (map-get? booking-payment-escrow booking-identifier) 
                           ERR-RESOURCE-NOT-FOUND))
  )
    ;; Verify cancellation authorization
    (asserts! (or (is-eq cancellation-requester-address booking-customer-address) 
                  (is-eq cancellation-requester-address assigned-provider-address)) ERR-UNAUTHORIZED-OPERATION)
    ;; Verify cancellation eligibility status
    (asserts! (or (is-eq current-booking-status pending-provider-acceptance) 
                  (is-eq current-booking-status confirmed-by-provider)) ERR-INVALID-STATUS-TRANSITION)
    
    ;; Process customer refund
    (try! (as-contract (stx-transfer? escrowed-refund-amount tx-sender booking-customer-address)))
    
    ;; Update booking cancellation status
    (map-set customer-booking-records booking-identifier 
             (merge booking-record-data {
               booking-lifecycle-status: booking-cancelled-by-party
             }))
    
    ;; Clear escrow payment account
    (map-delete booking-payment-escrow booking-identifier)
    
    (ok true)
  )
)

;; REPUTATION RATING SYSTEM

(define-public (submit-service-quality-rating 
  (booking-identifier uint) 
  (quality-rating-score uint) 
  (is-customer-rating-submission bool))
  (let (
    (booking-record-data (unwrap! (map-get? customer-booking-records booking-identifier) 
                          ERR-RESOURCE-NOT-FOUND))
    (referenced-service-identifier (get referenced-service-identifier booking-record-data))
    (service-listing-data (unwrap! (map-get? available-robotics-services referenced-service-identifier) 
                          ERR-RESOURCE-NOT-FOUND))
    (service-provider-address (get assigned-provider-address booking-record-data))
    (provider-account-data (unwrap! (map-get? registered-robotics-providers service-provider-address) 
                           ERR-RESOURCE-NOT-FOUND))
  )
    (asserts! (is-eq (get booking-lifecycle-status booking-record-data) service-delivery-completed) 
              ERR-INVALID-STATUS-TRANSITION)
    (asserts! (validate-rating-score quality-rating-score) ERR-RATING-VALUE-OUT-OF-RANGE)
    
    (if is-customer-rating-submission
      (begin
        (asserts! (is-eq (get booking-customer-address booking-record-data) tx-sender) ERR-UNAUTHORIZED-OPERATION)
        (asserts! (is-none (get customer-submitted-rating booking-record-data)) ERR-OPERATION-ALREADY-EXECUTED)
        
        ;; Update booking with customer rating submission
        (map-set customer-booking-records booking-identifier 
                 (merge booking-record-data {
                   customer-submitted-rating: (some quality-rating-score)
                 }))
        
        ;; Update service listing rating statistics
        (map-set available-robotics-services referenced-service-identifier 
                 (merge service-listing-data {
                   service-rating-points-sum: (+ (get service-rating-points-sum service-listing-data) quality-rating-score),
                   service-rating-count: (+ (get service-rating-count service-listing-data) u1)
                 }))
        
        ;; Update provider reputation statistics
        (map-set registered-robotics-providers service-provider-address 
                 (merge provider-account-data {
                   aggregated-rating-points: (+ (get aggregated-rating-points provider-account-data) quality-rating-score),
                   total-rating-submissions: (+ (get total-rating-submissions provider-account-data) u1)
                 }))
      )
      (begin
        (asserts! (is-eq service-provider-address tx-sender) ERR-UNAUTHORIZED-OPERATION)
        (asserts! (is-none (get provider-submitted-rating booking-record-data)) ERR-OPERATION-ALREADY-EXECUTED)
        
        ;; Update booking with provider rating submission
        (map-set customer-booking-records booking-identifier 
                 (merge booking-record-data {
                   provider-submitted-rating: (some quality-rating-score)
                 }))
      )
    )
    
    (ok true)
  )
)

;; PLATFORM ADMINISTRATION

(define-public (withdraw-accumulated-platform-revenue (withdrawal-amount-ustx uint))
  (begin
    (asserts! (verify-contract-administrator) ERR-UNAUTHORIZED-OPERATION)
    (asserts! (<= withdrawal-amount-ustx (var-get accumulated-platform-revenue)) 
              ERR-INSUFFICIENT-BALANCE)
    
    (try! (as-contract (stx-transfer? withdrawal-amount-ustx tx-sender contract-administrator)))
    (var-set accumulated-platform-revenue 
             (- (var-get accumulated-platform-revenue) withdrawal-amount-ustx))
    
    (ok true)
  )
)

;; PUBLIC QUERY FUNCTIONS

(define-read-only (get-provider-account-information (provider-address principal))
  (map-get? registered-robotics-providers provider-address)
)

(define-read-only (get-service-listing-information (service-identifier uint))
  (map-get? available-robotics-services service-identifier)
)

(define-read-only (get-booking-record-information (booking-identifier uint))
  (map-get? customer-booking-records booking-identifier)
)

(define-read-only (calculate-provider-average-rating (provider-address principal))
  (match (map-get? registered-robotics-providers provider-address)
    provider-account-data
      (if (> (get total-rating-submissions provider-account-data) u0)
        (some (/ (get aggregated-rating-points provider-account-data) 
                 (get total-rating-submissions provider-account-data)))
        none
      )
    none
  )
)

(define-read-only (calculate-service-average-rating (service-identifier uint))
  (match (map-get? available-robotics-services service-identifier)
    service-listing-data
      (if (> (get service-rating-count service-listing-data) u0)
        (some (/ (get service-rating-points-sum service-listing-data) 
                 (get service-rating-count service-listing-data)))
        none
      )
    none
  )
)

(define-read-only (get-platform-revenue-balance)
  (var-get accumulated-platform-revenue)
)

(define-read-only (get-booking-escrow-balance (booking-identifier uint))
  (map-get? booking-payment-escrow booking-identifier)
)

(define-read-only (get-provider-total-service-count (provider-address principal))
  (default-to u0 (map-get? provider-active-service-count provider-address))
)

(define-read-only (verify-provider-registration-status (provider-address principal))
  (is-some (map-get? registered-robotics-providers provider-address))
)

(define-read-only (get-comprehensive-platform-statistics)
  {
    total-platform-revenue-collected: (var-get accumulated-platform-revenue),
    next-available-service-identifier: (var-get current-service-identifier),
    next-available-booking-identifier: (var-get current-booking-identifier),
    platform-commission-rate-basis-points: platform-commission-basis-points
  }
)