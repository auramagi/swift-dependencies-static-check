//
//  Binary.swift
//
//
//  Created by Mikhail Apurin on 2024/04/11.
//

import Foundation

struct Binary: Hashable {
    enum ID {
        case main
    }

    let id: ID

    let url: URL
}
