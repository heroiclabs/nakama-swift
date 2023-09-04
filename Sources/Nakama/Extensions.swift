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
import SwiftProtobuf

extension BinaryInteger {
    var pbInt32Value: Google_Protobuf_Int32Value {
        return Google_Protobuf_Int32Value.with { $0.value = Int32(self) }
    }
    
    var pbInt64Value: Google_Protobuf_Int64Value {
        return Google_Protobuf_Int64Value.with { $0.value = Int64(self) }
    }
    
    var pbUint32Value: Google_Protobuf_UInt32Value {
        return Google_Protobuf_UInt32Value.with { $0.value = UInt32(self) }
    }
}

extension String {
    var jsonDictionary: [String: Any]? {
        guard let data = self.data(using: .utf8) else { return nil }
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            return nil
        }
    }
}
