//
//  PhotoCategory.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/22/26.
//
import SwiftData
import UIKit
@Model
class PhotoCategory:EntityPersistentModel {
    typealias DTO = PhotoCategoryDTO
    
    private(set) var id: UUID = UUID()
    var name: String
    var size: CGFloat { name.getSize() }
    
    init(id: UUID = UUID(), name: String){
        self.id = id
        self.name = name
    }
    
    func toDTO() -> PhotoCategoryDTO {
        PhotoCategoryDTO(id: self.id, name: self.name)
    }
}

struct PhotoCategoryDTO: DTOModel {
    typealias Entity = PhotoCategory
    
    let id: UUID
    let name: String
    let size: CGFloat
    
    static func == (lhs: PhotoCategoryDTO, rhs: PhotoCategoryDTO) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
        self.size = name.getSize()
    }
    
    func toEntity() -> PhotoCategory {
        PhotoCategory(id: self.id, name: self.name)
    }
}

//extension PhotoCategoryDTO {
//    func toEntity() -> PhotoCategory {
//        PhotoCategory(id: self.id, name: self.name)
//    }
//}
//extension PhotoCategory {
//    func toDTO() -> PhotoCategoryDTO {
//        PhotoCategoryDTO(id: self.id, name: self.name)
//    }
//}
