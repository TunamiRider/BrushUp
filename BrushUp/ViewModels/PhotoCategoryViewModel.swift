//
//  PhotoCategoryViewModel.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/23/26.
//
import Foundation
import SwiftData
@MainActor
@Observable public final class PhotoCategoryViewModel {
    
    var photoCategories: [PhotoCategoryDTO] = []
    var photoCategoryGrid: [[PhotoCategoryDTO]] = []
    private var swiftDataService: SwiftDataService<PhotoCategory, PhotoCategoryDTO>?
    
    
    let config: ModelConfiguration
    let container:ModelContainer
    
    private var screenWidth: CGFloat = 0
    private var screenHeight: CGFloat = 0
    
    // Get actual ModelContainer instance
    init() {
        config = ModelConfiguration(isStoredInMemoryOnly: false)
        container = try! ModelContainer(for: PhotoCategory.self, configurations: config)
    }
    func start(){
        Task { @MainActor in
            self.swiftDataService = SwiftDataService(
                modelContainer: container
            )
            //await _createDefaults()
            await loadData()
        }
    }
    
    func loadData() async {
        guard let service = swiftDataService else { return }
        
        photoCategories = (try? await service.fetchAll()) ?? []
        
        _calculatephotoCategoryGrid()
    }
    func fetchCount() async -> Int {
        guard let service = swiftDataService else { return 0 }
        
        return try! await service.fetchCount()
    }
    func save(_ model: PhotoCategoryDTO) async {
        guard let service = swiftDataService else { return }
        
        if await hasDuplicate(model.name) { return }
        
        _ = try! await service.save(model)
        
    }
    func hasDuplicate(_ name: String) async -> Bool {
        guard let service = swiftDataService else { return false }
        
        do {
            let predicate = #Predicate<PhotoCategory> { category in
                category.name.localizedStandardContains(name)
            }
            let descriptor = FetchDescriptor<PhotoCategory>(predicate: predicate)
            
            let count = try service.modelContainer.mainContext.fetch(descriptor)
            return !count.isEmpty
        } catch {
            print("Check failed: \(error)")
            return false
        }
    }
//    func delete(_ model: PhotoCategoryDTO) async {
//        guard let service = swiftDataService else { return }
//        _ = try! await service.delete(model)
//    }
    func deleteById(_ tagId: UUID) async {
        guard let service = swiftDataService else { return }
        _ = try! service.modelContainer.mainContext.delete(model: PhotoCategory.self, where: #Predicate{ tag in tag.id == tagId })
    }
    
    
//    private func _createDefaults() async {
//        guard let service = swiftDataService else { return }
//        let count = try! await service.fetchCount()
//        
//        guard count == 0 else { return }
//        let defaultValues = ["resturant", "animal", "Caffe", "nature", "arcitecture"]
//        let newDefaults: [PhotoCategoryDTO] = defaultValues.map {name in PhotoCategoryDTO(id: UUID(), name: name)}
//        
//        for dto in newDefaults {
//            _ = try! await service.save(dto)
//        }
//        
//        
//        await loadData()
//    }
    
    // Dispaly
    
    func updateScreenSize(width: CGFloat, height: CGFloat) {
        screenWidth = width
        screenHeight = height
    }
    private func _calculatephotoCategoryGrid() {
        var rows: [[PhotoCategoryDTO]] = []
        var currentRow: [PhotoCategoryDTO] = []
        
        var totalWidth: CGFloat = 0
        let screenWidth: CGFloat = screenWidth
        let wordSpacing: CGFloat = 14 /*Leading Padding*/ + 30 /*Trailing Padding*/ + 6 + 6 /*Leading & Trailing 6, 6 Spacing */
        
        guard !photoCategories.isEmpty else {
            photoCategoryGrid = []
            return
        }
        
        photoCategories.forEach{ category in
            
            totalWidth += (category.size + wordSpacing)
            
            if(totalWidth > screenWidth){
                totalWidth = (category.size + wordSpacing)
                rows.append(currentRow)
                currentRow.removeAll()
                currentRow.append(category)
            } else {
                currentRow.append(category)
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
            currentRow.removeAll()
        }
        
        self.photoCategoryGrid = rows
    }
    
    
    
}
