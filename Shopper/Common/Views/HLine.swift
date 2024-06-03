//
//  HLine.swift
//  Shopper
//
//  Created by Гіяна Князєва on 23.12.2022.
//

import SwiftUI

struct HLine: Shape {
    init() {}
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}
