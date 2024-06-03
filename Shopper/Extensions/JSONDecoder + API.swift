//
//  JSONDecoder + API.swift
//  Shopper
//
//  Created by Гіяна Князєва on 30.12.2022.
//

import Foundation

extension JSONDecoder {
    
    static var apiDateHandlingInstance: JSONDecoder {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }
    
}
