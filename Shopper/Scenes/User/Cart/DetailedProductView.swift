//
//  DetailedProductView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 30.12.2022.
//

import SwiftUI

struct DetailedProductView: View {
    
    let product: ProductResponse
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let imageUrlString = product.imageUrl, let imageUrl = URL(string: imageUrlString) {
                    AsyncImage(
                        url: imageUrl,
                        content: { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 250)
                                .clipped()
                                .contentShape(Rectangle())
                        },
                        placeholder: {
                            ProgressView()
                                .frame(width: UIScreen.main.bounds.width, height: 250)
                        }
                    )
                } else {
                    Spacer()
                        .frame(height: 100)
                }
                
                VStack(alignment: .leading, spacing: 25) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.name)
                                .font(.system(.title, weight: .semibold))
                                
                            Text(product.category)
                                .font(.system(.title2, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            UAHView(total: product.price)
                                .font(.system(.title, weight: .semibold))
                                
                            Text(product.isPricePerKilo ? "per kilo" : "per item")
                                .font(.system(.title2, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(product.description)
                        .font(.system(.title3))
                        .fixedSize()
                    
                    VStack {
                        HStack {
                            Group {
                                Text("Parameter")
                                
                                Text("Per 100g")
                            }
                            .font(.system(.title3, weight: .semibold))
                            .frame(height: 30)
                            .frame(maxWidth: .infinity)
                        }
                        .background { Color.gray.opacity(0.15) }
                        
                        HStack {
                            VStack {
                                let dataSource = zip(
                                    ["Calories", "Protein", "Carb", "Fat"],
                                    [product.caloriesPer100g, product.protein, product.carb, product.fat]
                                )
                                ForEach(Array(dataSource), id:\.0) { text, amount in
                                    VStack(spacing: 0) {
                                        HStack {
                                            Group {
                                                Text(text)
                                                
                                                Text(String(format: "%.1f", amount))
                                            }
                                                .font(.system(.title3))
                                                .frame(height: 30)
                                                .frame(maxWidth: .infinity)
                                        }
                                        
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
        }
        .ignoresSafeArea()
    }
}

struct DetailedProductView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedProductView(product: ProductResponse(id: "woeipwjr", name: "Some name here", description: "Long description or something sadjalksjd", upc: "239489230", pricePerKilo: 24.48, weightPerItem: 1, isPricePerKilo: false, caloriesPer100g: 230, protein: 12, fat: 6, carb: 15, category: "meat", imageUrl: "https://images.unsplash.com/photo-1526512340740-9217d0159da9?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dmVydGljYWx8ZW58MHx8MHx8&w=1000&q=80"))
        
        //"https://media.wired.com/photos/5b493b6b0ea5ef37fa24f6f6/125:94/w_2393,h_1800,c_limit/meat-80049790.jpg"
    }
}
