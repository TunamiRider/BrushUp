//
//  SwiftDataService.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/22/26.
//
import SwiftData
import Foundation
@ModelActor
actor SwiftDataService<E, D>: SwiftDataRepository
where E: EntityPersistentModel, D: DTOModel {

    typealias Entity = E
    typealias DTO = D
    private var _fetchDescriptor: FetchDescriptor<E> = FetchDescriptor<E>()
     var modelContext: ModelContext { modelExecutor.modelContext }
    
    
    func setFetchDescriptor(_ descriptor: FetchDescriptor<E>) async {
        self._fetchDescriptor = descriptor
    }
    
    func fetchAll() async throws -> [D] {
        let entities: [E] = try modelContext.fetch(_fetchDescriptor)
        return entities.map{ $0.toDTO() as! D }
    }
    func fetchCount() async throws -> Int {
        let descriptor = FetchDescriptor<E>(predicate: _fetchDescriptor.predicate)
        return try modelContext.fetchCount(descriptor)
    }
    
    func save(_ model: DTO) async throws {
        let entity = model.toEntity() as! E
        modelContext.insert(entity)
        try modelContext.save()
    }
    func delete(_ model: DTO) async throws {
        let entity = model.toEntity() as! E
        modelContext.delete(entity)
        try modelContext.save()
    }
    func deleteById(_ tagId: UUID) async {
        _ = try! modelContext.delete(model: E.self, where: #Predicate{ tag in tag.id as! UUID == tagId })
    }
    
    func fetchWithPredicate(_ descriptor: FetchDescriptor<E>) async throws -> [E] {
        let predicateDescriptor = FetchDescriptor<E>(
            predicate: descriptor.predicate
        )
        return try modelContext.fetch(predicateDescriptor)
    }

    

    func create(_ mode: DTO) async throws {
        try await save(mode)
    }
}
