/*
 * Copyright © 2023 Heroic Labs
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

/// Validated Purchase stored by Nakama.
public struct ValidatedPurchase
{
    /// Timestamp when the receipt validation was stored in DB.
    let createTime: Date
    
    /// Whether the purchase was done in production or sandbox environment.
    let environment: Nakama_Api_StoreEnvironment
    
    /// Purchase Product ID.
    let productId: String
    
    /// Raw provider validation response.
    let providerResponse: String
    
    /// Timestamp when the purchase was done.
    let purchaseTime: Date
    
    /// Timestamp when the purchase was refunded. Set to UNIX
    let refundTime: Date
    
    /// Whether the purchase had already been validated by Nakama before.
    let seenBefore: Bool
    
    /// Store identifier
    let store: Nakama_Api_StoreProvider
    
    /// Purchase Transaction ID.
    let transactionId: String
    
    /// Timestamp when the receipt validation was updated in DB.
    let updateTime: Date
    
    /// Purchase User ID.
    let userId: String
}

/// Validate IAP response.
public struct ValidatePurchaseResponse
{
    /// Newly seen validated purchases.
    let validatedPurchases: [ValidatedPurchase]
}
