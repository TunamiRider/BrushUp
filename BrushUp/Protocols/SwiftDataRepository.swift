//
//  SwiftDataRepository.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/22/26.
//
import SwiftData
protocol SwiftDataRepository {
    associatedtype Entity: EntityPersistentModel
    associatedtype DTO: DTOModel
    
    func fetchAll() async throws -> [DTO]
    func fetchCount() async throws -> Int
    func save(_ model: DTO) async throws
    func delete(_ model: DTO) async throws
    func create(_ mode: DTO) async throws
    // func setFetchDescriptor(_ descriptor: FetchDescriptor<Entity>) async
}

protocol EntityPersistentModel: PersistentModel {
    associatedtype DTO: DTOModel
    
    func toDTO() -> DTO
    // init(from dto: DTO)
}
protocol DTOModel: Sendable & Identifiable & Hashable {
    associatedtype Entity: EntityPersistentModel
    
    func toEntity() -> Entity
    // init(from entity: Entity)
}
