//
//  TagBackgroundActor.swift
//  ModelActor
//
//  Created by Yuki Suzuki on 7/9/25.
//

import Foundation
import SwiftData
import UIKit

@available(iOS 17, *)
@ModelActor
actor TagBackgroundActor: Sendable {
    
    private var context: ModelContext { modelExecutor.modelContext }
    
    private let exampleTags = ["resturant", "animal", "Caffe", "nature", "arcitecture"]
    
    func persistTags(){
        var newTags = [Tag]()
        exampleTags.forEach { newTags.append(Tag(name: "\($0)")) }
        
        newTags.forEach { context.insert($0) }
        try? context.save()
        print("Data persisted")
    }
    
    func fetchData() async throws -> [TagDTO] {
        let fetchDescriptor = FetchDescriptor<Tag>(sortBy: [SortDescriptor(\Tag.name)])
        let tags: [Tag] = try context.fetch(fetchDescriptor)
        let tagDTOs: [TagDTO] = tags.map{TagDTO(id: $0.id, name: $0.name)}
        return tagDTOs
    }
    
    func fetchCount() async -> Int {
        let fetchDescriptor = FetchDescriptor<Tag>()
        let modelcount = try? context.fetchCount(fetchDescriptor)
        return modelcount ?? 0
    }
    
    func saveData(_ tagName: String) async {
        let newTag = Tag(name: tagName)
        context.insert(newTag)
        try? context.save()
        print("Data saved \(newTag.name)")
    }
    func deleteData(_ tagId: UUID) async {
        try? context.delete(model: Tag.self, where: #Predicate{ tag in tag.id == tagId })
    }
    
}

@Observable final class TagsQueryViewModel: Sendable {
    
    let modelContainer: ModelContainer
    let backgroundActor: TagBackgroundActor
    
    init(modelContainer: ModelContainer){
        self.modelContainer = modelContainer
        self.backgroundActor = TagBackgroundActor(modelContainer: self.modelContainer)
    }
    
    func backgroundFetch() async throws -> [TagDTO] {
        //let backgroundActor = TagBackgroundActor(modelContainer: modelContainer)
        
        let start = Date()
        let result = try await self.backgroundActor.fetchData()
        print("Background fetch takes \(Date().timeIntervalSince(start))")
        return result
    }
    
    func createDatabase() async {
        // let backgroundActor = TagBackgroundActor(modelContainer: modelContainer)
        let existingTagsCount = await self.backgroundActor.fetchCount()
        guard existingTagsCount == 0 else {
            print("User models already exists")
            return
        }
        await self.backgroundActor.persistTags()
        let testCount = await self.backgroundActor.fetchCount()
        let _ = print("create database count: \(testCount)")
    }
    
    func saveTag(_ name: String) async {
        // let backgroundActor = TagBackgroundActor(modelContainer: modelContainer)
        await self.backgroundActor.saveData(name)
    }
    
    func deleteTag(_ id: UUID) async{
        await self.backgroundActor.deleteData(id)
    }
    
}

@Model
class Tag {
    private(set) var id: UUID = UUID()
    var name: String
    var size: CGFloat = 0
    
    init(id: UUID = UUID(), name: String){
        self.id = id
        self.name = name
        self.size = name.getSize()
    }
}

final class TagDTO: Sendable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let size: CGFloat
    
    static func == (lhs: TagDTO, rhs: TagDTO) -> Bool {
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
}

extension String{
    func getSize() -> CGFloat{
        let font = UIFont.systemFont(ofSize: 16)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (self as NSString).size(withAttributes: attributes)
        return size.width
    }
}
