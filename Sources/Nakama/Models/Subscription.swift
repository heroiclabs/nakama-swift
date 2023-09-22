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

/// User validated subscription.
public struct ValidatedSubscription {
    /// Whether the subscription is currently active or not.
    let active: Bool
    
    /// UNIX Timestamp when the receipt validation was stored in DB.
    let createTime: Date
    
    /// Whether the purchase was done in production or sandbox environment.
    let environment: Nakama_Api_StoreEnvironment
    
    /// Subscription expiration time. The subscription can still be auto-renewed to extend the expiration time further.
    let expiryTime: Date
    
    /// Purchase Original transaction ID (we only keep track of the original subscription, not subsequent renewals).
    let originalTransactionId: String
    
    /// Purchase Product ID.
    let productId: String
    
    /// Raw provider notification body.
    let providerNotification: String
    
    /// Raw provider validation response body.
    let providerResponse: String
    
    /// UNIX Timestamp when the purchase was done.
    let purchaseTime: Date
    
    /// Subscription refund time. If this time is set, the subscription was refunded.
    let refundTime: Date
    
    /// Store identifier
    let store: Nakama_Api_StoreProvider
    
    /// UNIX Timestamp when the receipt validation was updated in DB.
    let updateTime: Date
    
    /// Subscription User ID.
    let userId: String
}

/// Validate Subscription response.
public struct ValidateSubscriptionResponse {
    let validatedSubscription: ValidatedSubscription
}

/// A list of validated subscriptions stored by Nakama.
public struct SubscriptionList {
    /// The cursor to send when retrieving the next page, if any.
    let Cursor: String
    
    /// The cursor to send when retrieving the previous page, if any.
    let PrevCursor: String
    
    /// Stored validated subscriptions.
    let validatedSubscriptions: [ValidatedSubscription]
}
