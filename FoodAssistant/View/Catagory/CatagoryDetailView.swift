//
//  CatagoryDetailView.swift
//  FoodAssistant
//
//  Created by Choi Wai Lap on 18/11/2022.
//

import SwiftUI

struct CatagoryDetailView: View {
    
    @StateObject var vm: CatagoryDetailViewModel
    
    init(
        catagory: Catagory = .bakery
    ) {
        let vm = CatagoryDetailViewModel(catagory: catagory)
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                SpecialForYou()
                EatHealthier()
                MostDelicious()
                EvilButTempting()
                YoursFavourite()
                NewMenu()
                Rectangle()
                    .frame(height: screenHeight/8)
                    .opacity(0)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationTitle("\(vm.catagory.rawValue)")
        .productLargeNavigationBar()
        .nativeSearchBar(text: vm.searchedProduct, placeHolder: "Search Product")
        
    }
    
    fileprivate struct SpecialForYou: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Special for you")
                    .productFont(.bold, relativeTo: .title3)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                Text("Saffron Karak French Toast topped with karak ganache")
                    .productFont(.regular, relativeTo: .body)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                Button {
                    
                } label: {
                    Text("Learn More")
                        .productFont(.bold, relativeTo: .callout)
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.adaptable(light: .white, dark: .black))
                        .cornerRadius(10, style: .continuous)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .background(Color.black.opacity(0.2))
            .background {
                Image("Appicon")
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .cornerRadius(20, style: .continuous)
            .padding(.horizontal)
        }
    }
    
    fileprivate struct EatHealthier: View {
        var body: some View {
            VStack {
                VStack(alignment: .leading) {
                    Text("Eat Healthier")
                        .productFont(.bold, relativeTo: .title2)
                        .foregroundColor(.primary)
                    Text("The best choices for cutting weight")
                        .productFont(.regular, relativeTo: .body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .trailing) {
                    Button {
                        
                    } label: {
                        HStack {
                            Text("View All")
                                .productFont(.bold, relativeTo: .callout)
                            Image(systemName: "chevron.right")
                                .font(.callout)
                        }
                    }
                }
                .padding(.horizontal, 24)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(0..<2, id: \.self) { _ in
                            Color.adaptable(light: .black, dark: .white)
                                .frame(width: 250, height: 150)
                                .cornerRadius(20, style: .continuous)
                                .padding(.leading)
                        }
                    }
                    .padding(.leading, 8)
                }
            }
        }
    }
    
    fileprivate struct MostDelicious: View {
        var body: some View {
            VStack {
                VStack(alignment: .leading) {
                    Text("Most Delicious")
                        .productFont(.bold, relativeTo: .title2)
                        .foregroundColor(.primary)
                    Text("You wouldn’t want to miss them")
                        .productFont(.regular, relativeTo: .body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .trailing) {
                    Button {
                        
                    } label: {
                        HStack {
                            Text("View All")
                                .productFont(.bold, relativeTo: .callout)
                            Image(systemName: "chevron.right")
                                .font(.callout)
                        }
                    }
                }
                .padding(.horizontal, 24)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(0..<2, id: \.self) { _ in
                            Color.adaptable(light: .black, dark: .white)
                                .frame(width: 250, height: 150)
                                .cornerRadius(20, style: .continuous)
                                .padding(.leading)
                        }
                    }
                    .padding(.leading, 8)
                }
            }
        }
    }
    
    fileprivate struct EvilButTempting: View {
        var body: some View {
            VStack {
                VStack(alignment: .leading) {
                    Text("Evil but Tempting")
                        .productFont(.bold, relativeTo: .title2)
                        .foregroundColor(.primary)
                    Text("They are shouting “EAT ME!”")
                        .productFont(.regular, relativeTo: .body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .trailing) {
                    Button {
                        
                    } label: {
                        HStack {
                            Text("View All")
                                .productFont(.bold, relativeTo: .callout)
                            Image(systemName: "chevron.right")
                                .font(.callout)
                        }
                    }
                }
                .padding(.horizontal, 24)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(0..<2, id: \.self) { _ in
                            Color.adaptable(light: .black, dark: .white)
                                .frame(width: 250, height: 150)
                                .cornerRadius(20, style: .continuous)
                                .padding(.leading)
                        }
                    }
                    .padding(.leading, 8)
                }
            }
        }
    }
    
    fileprivate struct YoursFavourite: View {
        var body: some View {
            VStack {
                VStack(alignment: .leading) {
                    Text("Yours Favourite")
                        .productFont(.bold, relativeTo: .title2)
                        .foregroundColor(.primary)
                    Text("You eat them everyday, yummy!")
                        .productFont(.regular, relativeTo: .body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .trailing) {
                    Button {
                        
                    } label: {
                        HStack {
                            Text("View All")
                                .productFont(.bold, relativeTo: .callout)
                            Image(systemName: "chevron.right")
                                .font(.callout)
                        }
                    }
                }
                .padding(.horizontal, 24)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(0..<2, id: \.self) { _ in
                            VStack(spacing: 0) {
                                Color.adaptable(light: .black, dark: .white)
                                    .frame(width: 250, height: 150)
                                    .cornerRadius(20, style: .continuous)
                                VStack(alignment: .leading) {
                                    Text("Cafe Bakery")
                                        .productFont(.bold, relativeTo: .title2)
                                        .foregroundColor(.primary)
                                    Text("Red Bread with French Nuts")
                                        .productFont(.regular, relativeTo: .body)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top)
                                Spacer(minLength: 0)
                                HStack(alignment: .bottom) {
                                    Text("30")
                                        .productFont(.bold, relativeTo: .body)
                                        .foregroundColor(.systemBlue)
                                    Text("Kcal")
                                        .productFont(.bold, relativeTo: .subheadline)
                                        .foregroundColor(.systemBlue)
                                    Spacer()
                                    Button {
                                        
                                    } label: {
                                        Image(systemName: "heart")
                                            .foregroundColor(.systemRed)
                                    }
                                }
                            }
                            .padding([.horizontal, .bottom])
                            .frame(width: 250, height: 275, alignment: .top)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.gray, lineWidth: 1)
                            }
                            .padding(.leading)
                            .padding(.vertical, 1)
                        }
                    }
                    .padding(.leading, 8)
                }
            }
        }
    }
    
    fileprivate struct NewMenu: View {
        var body: some View {
            VStack {
                VStack(alignment: .leading) {
                    Text("New Menu")
                        .productFont(.bold, relativeTo: .title2)
                        .foregroundColor(.primary)
                    Text("You eat them everyday, yummy!")
                        .productFont(.regular, relativeTo: .body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(alignment: .trailing) {
                    Button {
                        
                    } label: {
                        HStack {
                            Text("View All")
                                .productFont(.bold, relativeTo: .callout)
                            Image(systemName: "chevron.right")
                                .font(.callout)
                        }
                    }
                }
                .padding(.horizontal, 24)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(0..<2, id: \.self) { _ in
                            VStack(spacing: 0) {
                                Color.adaptable(light: .black, dark: .white)
                                    .frame(width: 250, height: 150)
                                    .cornerRadius(20, style: .continuous)
                                VStack(alignment: .leading) {
                                    Text("Cafe Bakery")
                                        .productFont(.bold, relativeTo: .title2)
                                        .foregroundColor(.primary)
                                    Text("Red Bread with French Nuts")
                                        .productFont(.regular, relativeTo: .body)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top)
                                Spacer(minLength: 0)
                                HStack(alignment: .bottom) {
                                    Text("30")
                                        .productFont(.bold, relativeTo: .body)
                                        .foregroundColor(.systemBlue)
                                    Text("Kcal")
                                        .productFont(.bold, relativeTo: .subheadline)
                                        .foregroundColor(.systemBlue)
                                    Spacer()
                                    Button {
                                        
                                    } label: {
                                        Image(systemName: "heart")
                                            .foregroundColor(.systemRed)
                                    }
                                }
                            }
                            .padding([.horizontal, .bottom])
                            .frame(width: 250, height: 275, alignment: .top)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.gray, lineWidth: 1)
                            }
                            .padding(.leading)
                            .padding(.vertical, 1)
                        }
                    }
                    .padding(.leading, 8)
                }
            }
        }
    }
}

struct CatagoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CatagoryDetailView()
        }
    }
}
