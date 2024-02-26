//
//  File.swift
//  ssc-vision
//
//  Created by Nikolai Madlener on 24.02.24.
//

import Foundation

struct TrashModel {
    var type: TrashType
    var entityName: String
}

enum TrashType: String {
    case Recycle = "recycle", Solid = "solid", Organic = "organic"
}

extension TrashModel {
    static func getData() -> [TrashModel] {
        return [
            TrashModel(type: .Organic, entityName: "Apple"),
            TrashModel(type: .Organic, entityName: "Banana"),
            TrashModel(type: .Organic, entityName: "Salad"),
            
            TrashModel(type: .Recycle, entityName: "Milk"),
            TrashModel(type: .Recycle, entityName: "Yoghurt"),
            TrashModel(type: .Recycle, entityName: "Lentils"),
            TrashModel(type: .Recycle, entityName: "Ketchup"),
            TrashModel(type: .Recycle, entityName: "Juice"),
            TrashModel(type: .Recycle, entityName: "Eggbasket"),
            TrashModel(type: .Recycle, entityName: "Creamcheese"),
            TrashModel(type: .Recycle, entityName: "Beer"),

            TrashModel(type: .Solid, entityName: "Shoe"),
            TrashModel(type: .Solid, entityName: "Sock"),
        ]
    }
}
