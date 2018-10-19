/*
 * Copyright 2018 Heroic Labs
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

fileprivate var nakama_associated_cursor = "nakama_cursor"

extension Array {
  internal var _cursor: String? {
    get {
      return objc_getAssociatedObject(self, &nakama_associated_cursor) as? String
    }
    set(newValue) {
      objc_setAssociatedObject(self, &nakama_associated_cursor, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
  }
  
  /**
   - Returns: Optional cursor associated with this data
   */
  public var cursor: String? {
    return _cursor
  }
}
