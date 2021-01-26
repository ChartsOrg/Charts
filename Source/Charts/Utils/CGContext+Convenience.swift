//
//  CGContext+Convenience.swift
//  Charts
//
//  Created by Jacob Christie on 2021-01-26.
//

import Foundation

extension CGContext {
    func perform(transaction: () throws -> Void) rethrows {
        saveGState()
        try transaction()
        restoreGState()
    }
}
