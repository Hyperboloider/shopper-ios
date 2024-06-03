//
//  UAHView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 20.12.2022.
//

import SwiftUI

func UAHView(total: Double) -> Text {
    return Text(String(format: "%.2f", total) + " ₴")
}
