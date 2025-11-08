//
//  Array+Extension.swift
//  BelDetailing
//
//  Created by Achraf Benali on 08/11/2025.
//

extension Collection {
  subscript(safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
