//
//  ShoppingListsView.swift
//  Shopper
//
//  Created by Illia Kniaziev on 26.04.2024.
//

import SwiftUI
import Combine
import RealmSwift

struct WaitingView<Content: View>: View {
    
    private final class WaitingViewModel: ObservableObject {
        @Published var mappedState: NetworkState = .none
        @Published var isClosed = false
        private var bag = Set<AnyCancellable>()
        init(statePublisher: AnyPublisher<NetworkState, Never>) {
            statePublisher
                .sink { [weak self] originalState in
                    self?.mappedState = originalState
                }
                .store(in: &bag)
            
            $isClosed
                .filter { $0 }
                .sink { [weak self] _ in
                    self?.mappedState = .none
                }
                .store(in: &bag)
        }
    }
    
    init(refetchAction: @escaping () -> Void, networkStatePublisher: AnyPublisher<NetworkState, Never>, contentBuilder: @escaping () -> Content) {
        self.refetchAction = refetchAction
        self.contentBuilder = contentBuilder
        self._viewModel = StateObject(wrappedValue: WaitingViewModel(statePublisher: networkStatePublisher))
    }
    
    let refetchAction: () -> Void
    let contentBuilder: () -> Content
    @StateObject private var viewModel: WaitingViewModel
    var body: some View {
        switch viewModel.mappedState {
        case .waiting:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                .scaleEffect(x: 2, y: 2)
        case .failure(let error):
            VStack(spacing: 16) {
                Text("Error: \((error as? NetworkingService.NetworkingError)?.localizedDescription ?? "None")")
                Button {
                    refetchAction()
                } label: {
                    Label("Try again", systemImage: "arrow.clockwise")
                }
                Button {
                    viewModel.isClosed = true
                } label: {
                    Label("Dismiss", systemImage: "xmark")
                }
            }
            .padding(20)
        default:
            contentBuilder()
        }
    }
}

struct ShoppingListsView: View {
    
    @State var newListName: String = ""
    @EnvironmentObject var viewModel: ShoppingListModel
    
    var body: some View {
        NavigationView {
//            WaitingView(
//                refetchAction: viewModel.fetchLists,
//                networkStatePublisher: viewModel.$networkingState.eraseToAnyPublisher()) {
                List {
                    if !viewModel.ownShoppingLists.isEmpty {
                        Section(header: Text("Own Shopping Lists")) {
                            ForEach(viewModel.ownShoppingLists, id: \.id) { list in
                                NavigationLink(
                                    destination: ShoppingListDetailView(
                                        viewModel: .init(
                                            networkingService: viewModel.networkingService,
                                            listId: list.id,
                                            isOwnList: true
                                        )
                                    )
                                ) {
                                    ListPreview(list)
                                }
                            }
                            .onDelete { indexSet in
                                viewModel.deleteOwn(ids: indexSet.compactMap { index in
                                    guard index < viewModel.ownShoppingLists.count else { return nil }
                                    return viewModel.ownShoppingLists[index].id
                                })
                            }
                        }
                    }
                    
                    if !viewModel.otherShoppingLists.isEmpty {
                        Section(header: Text("Other Shopping Lists")) {
                            ForEach(viewModel.otherShoppingLists, id: \.id) { list in
                                NavigationLink(
                                    destination: ShoppingListDetailView(
                                        viewModel: .init(
                                            networkingService: viewModel.networkingService,
                                            listId: list.id,
                                            isOwnList: false
                                        )
                                    )
                                ) {
                                    ListPreview(list)
                                }
                            }
                            .onDelete { indexSet in
                                viewModel.deleteOther(ids: indexSet.compactMap { index in
                                    guard index < viewModel.otherShoppingLists.count else { return nil }
                                    return viewModel.otherShoppingLists[index].id
                                })
                            }
                        }
                    }
                    
                    Section(header: Text("Add a new list")) {
                        InputField(text: $newListName, title: "New list's name", placeholder: "Dinner🥘", focus: true, onSubmit: {
                            viewModel.createList(newListName: newListName)
                        })
                        
                        Button {
                            viewModel.createList(newListName: newListName)
                            newListName.removeAll()
                        } label: {
                            HStack {
                                Text("Add")
                                    .font(.system(.title3, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(minWidth: 100, maxWidth: 260, minHeight: 42, maxHeight: 42, alignment: .center)
                            .background(newListName.isEmpty ? Color.gray : Color.green )
                            .cornerRadius(21)
                        }
                        .frame(maxWidth: .infinity)
                        .disabled(newListName.isEmpty)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .navigationTitle("Shopping Lists")
            }
        
//        }
    }
    
    @ViewBuilder
    private func ListPreview(_ list: ShoppingList) -> some View {
        VStack(alignment: .leading) {
            Text(list.name)
                .font(.system(size: 20))
            
            HStack(spacing: 32) {
                ListPreviewInfoItem(
                    text: "\(list.products.count) \(list.products.count > 1 ? "items" : "item")",
                    imageName: "carrot"
                )
                
                ListPreviewInfoItem(
                    text: "\(list.users.count)",
                    imageName: "person.fill"
                )
            }
        }
    }
    
    @ViewBuilder
    private func ListPreviewInfoItem(text: String, imageName: String) -> some View {
        HStack {
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 18)
                .foregroundStyle(Color.accentColor)
            Text(text)
        }
    }
}

#Preview {
    ShoppingListsView()
        .environmentObject(ShoppingListModel(networkingService: NetworkingService(), isUserSignedInPublisher: Just(false).eraseToAnyPublisher()))
}
