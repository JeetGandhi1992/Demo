//
//  DiscountSectionModel.swift
//  Din Din Demo
//
//  Created by jeet_gandhi on 8/11/20.
//

import UIKit
import RxDataSources

public struct DiscountSectionModel {
    var header: String
    public var items: [DiscountCellModel]

    init(header: String? = "", items: [DiscountCellModel]) {
        self.header = header!
        self.items = items
    }
}

extension DiscountSectionModel: SectionModelType {
    public typealias Item = DiscountCellModel

    public init(original: DiscountSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

extension DiscountSectionModel: Equatable {
    public static func == (lhs: DiscountSectionModel, rhs: DiscountSectionModel) -> Bool {
        return lhs.header == rhs.header
            && lhs.items == rhs.items

    }
}

public struct DiscountCellModel {
    var discount: UIColor
}

extension DiscountCellModel: Equatable {
    public static func == (lhs: DiscountCellModel, rhs: DiscountCellModel) -> Bool {
        return lhs.discount == rhs.discount
    }
}



