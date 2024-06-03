//
//  CreateProductRequest.swift
//  Shopper
//
//  Created by Гіяна Князєва on 21.12.2022.
//

import Foundation
import MultipartFormData

final class CreateProductRequest: PlainRequest {
    init?(body: Body) {
        let uuid = UUID().uuidString
        let headers = ["Content-Type" : "multipart/form-data; boundary=\"\(uuid)\""]
        if let body = try? body.multipartData(boundary: uuid).httpBody {
            super.init(endpoint: APIPath.Product.products, method: .post, headers: headers, body: body, authorizationStrategy: AuthorizedRequestStrategy())
        } else {
            return nil
        }
    }
}

extension CreateProductRequest {
    struct Body: Encodable {
        let name: String
        let description: String
        let upc: String
        let price: Double
        let isPricePerKilo: Bool
        let weightPerItem: Double
        let caloriesPer100g: Double
        let protein: Double
        let fat: Double
        let carb: Double
        let categoryId: String
        let imageData: Data?
        
        func multipartData(boundary: String) throws -> MultipartFormData {
            let boundary = try Boundary(uncheckedBoundary: boundary)
            return try MultipartFormData(boundary: boundary) {
                Subpart {
                    ContentDisposition(name: "name")
                } body: {
                    Data(name.utf8)
                }

                Subpart {
                    ContentDisposition(name: "description")
                } body: {
                    Data(description.utf8)
                }
                
                Subpart {
                    ContentDisposition(name: "upc")
                } body: {
                    Data(upc.utf8)
                }
                
                Subpart {
                    ContentDisposition(name: "price")
                } body: {
                    Data(String(price).utf8)
                }
                
                Subpart {
                    ContentDisposition(name: "isPricePerKilo")
                } body: {
                    Data(String(isPricePerKilo).utf8)
                }
                
                Subpart {
                    ContentDisposition(name: "weightPerItem")
                } body: {
                    Data(String(weightPerItem).utf8)
                }
                
                Subpart {
                    ContentDisposition(name: "caloriesPer100g")
                } body: {
                    Data(String(caloriesPer100g).utf8)
                }
                
                Subpart {
                    ContentDisposition(name: "protein")
                } body: {
                    Data(String(protein).utf8)
                }
                
                Subpart {
                    ContentDisposition(name: "fat")
                } body: {
                    Data(String(fat).utf8)
                }
                
                Subpart {
                    ContentDisposition(name: "carb")
                } body: {
                    Data(String(carb).utf8)
                }
                
                Subpart {
                    ContentDisposition(name: "categoryId")
                } body: {
                    Data(String(categoryId).utf8)
                }
                
                if let imageData {
                    try Subpart {
//                        ContentDisposition(name: "file")
                        try ContentDisposition(uncheckedName: "file", uncheckedFilename: "file")
                        ContentType(mediaType: .applicationOctetStream)
                    } body: {
                        return imageData
                    }
                }
            }
        }
    }
}
