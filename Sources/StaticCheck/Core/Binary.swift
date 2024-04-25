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

extension Binary {
    struct Sort: Comparable {
        let binaryType: Int

        let name: String

        static func < (lhs: Binary.Sort, rhs: Binary.Sort) -> Bool {
            lhs.binaryType == rhs.binaryType
            ? lhs.name < rhs.name
            : lhs.binaryType < rhs.binaryType
        }
    }

    var sort: Sort {
        switch self.id {
        case .main: .init(binaryType: 0, name: name)
        }
    }

    var name: String {
        url.lastPathComponent
    }
}
