//
//  PhotoInputView.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/21/26.
//

import SwiftUI
import SwiftData
struct PhotoCategoryView: View {
    
    @State private var photoCategoryViewModel = PhotoCategoryViewModel()
    @State var tagText = ""
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(){
                HStack{
                    photoSearch()
                }.padding()
                
                
                listCategories()
            }
            .onAppear{
                photoCategoryViewModel.updateScreenSize(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .task {
            photoCategoryViewModel.start()
        }
    }
    
    @ViewBuilder
    fileprivate func listCategories() -> some View {
        if photoCategoryViewModel.photoCategoryGrid.isEmpty {
            Image("Mascot")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            Text("No tags applied.")
                .font(AppConstants.mediumRoundedFont)
                .foregroundStyle(.white.opacity(0.6))
        }
        ForEach(photoCategoryViewModel.photoCategoryGrid, id:\.self){ rows in
            HStack(spacing: 6){
                ForEach(rows){ row in
                    Text(row.name)
                        .font(.system(size: 16))
                        .padding(.leading, 14)
                        .padding(.trailing, 30)
                        .padding(.vertical, 8)
                        .foregroundStyle(.white)
                        .background(
                            ZStack(alignment: .trailing){
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.gray.opacity(0.3))
                                Button{
                                    Task{
                                        await photoCategoryViewModel.deleteById(row.id)
                                        await photoCategoryViewModel.loadData()
                                    }
                                    
                                } label:{
                                    Image(systemName: "xmark")
                                        .frame(width: 12, height: 12)
                                        .padding(.trailing, 8)
                                        .font(.system(size: 12))
                                        .foregroundColor(.white)
                                }
                            }
                        )
                }
            }
        }
        
        if !photoCategoryViewModel.photoCategoryGrid.isEmpty {
            Image("Mascot")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .offset(x: 35)
        }
    }
    @ViewBuilder
    fileprivate func photoSearch() -> some View {


        HStack {
            Image(systemName: "tag")
                .foregroundStyle(.gray.opacity(0.9))
            
            TextField("", text: $tagText, prompt: Text("Enter Tag...")
                .foregroundStyle(.gray.opacity(0.9)))
                .font(AppConstants.mediumRoundedFont)
                .foregroundStyle(.gray.opacity(0.9))
                .tint(.gray.opacity(0.9))
                .textInputAutocapitalization(.never)
            
            resetButton()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.gray.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .onSubmit {
            Task{
                await photoCategoryViewModel.save(PhotoCategory(name: tagText).toDTO())
                await photoCategoryViewModel.loadData()
                tagText = ""
            }
        }
    }
    @ViewBuilder
    fileprivate func resetButton() -> some View {
        Button(action: {
            tagText = ""
        }) {
            Image(systemName: "multiply.circle.fill")
                .font(AppConstants.mediumRoundedFont)
                .foregroundColor(AppConstants.spaceblack.opacity(0.6))
                .padding(1)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(.gray.opacity(0.9))
                )
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Circle())
    }
}

#Preview {
    ZStack{
        PhotoCategoryView()
    }.background(AppConstants.spaceblack.ignoresSafeArea())
    
}
