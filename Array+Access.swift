//
//  Array+Access.swift
//  Charts
//
//  Created by Kurt Jacobs on 2022/03/18.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
