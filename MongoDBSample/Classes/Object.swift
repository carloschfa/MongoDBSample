//
//  Created by Carlos Henrique Antunes on 2/26/20.
//  Copyright © 2020 Carlos Henrique Antunes. All rights reserved.
//

import Foundation

struct Object: Codable {
  let objectId: String
  let category: String
  let text: String
  let number: Int
  let boolean: Bool
  let createdAt: String
  let updatedAt: String?
  
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
  
  
}
