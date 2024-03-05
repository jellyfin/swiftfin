//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import CollectionVGrid
import Defaults
import JellyfinAPI
import SwiftUI

struct PagingLibraryView<Element: Poster>: View {

    @Default(.Customization.Library.viewType)
    private var libraryViewType
    @Default(.Customization.Library.listColumnCount)
    private var listColumnCount

    @EnvironmentObject
    private var router: LibraryCoordinator<Element>.Router

    @StateObject
    private var viewModel: PagingLibraryViewModel<Element>

    @State
    private var layout: CollectionVGridLayout

    init(viewModel: PagingLibraryViewModel<Element>) {
        self._viewModel = StateObject(wrappedValue: viewModel)

        let initialLibraryViewType = Defaults[.Customization.Library.viewType]
        let initialListColumnCount = Defaults[.Customization.Library.listColumnCount]

        if UIDevice.isPhone {
            layout = Self.phoneLayout(libraryViewType: initialLibraryViewType)
        } else {
            layout = Self.padLayout(
                libraryViewType: initialLibraryViewType,
                listColumnCount: initialListColumnCount
            )
        }
    }

    // MARK: onSelect

    private func onSelect(_ element: Element) {
        switch element {
        case let element as BaseItemDto:
            select(item: element)
        case let element as BaseItemPerson:
            select(person: element)
        default:
            fatalError("Used an unexpected type within a `PagingLibaryView`?")
        }
    }

    private func select(item: BaseItemDto) {
        switch item.type {
        case .collectionFolder, .folder:
            let viewModel = ItemLibraryViewModel(parent: item)
            router.route(to: \.library, viewModel)
        default:
            router.route(to: \.item, item)
        }
    }

    private func select(person: BaseItemPerson) {
        let viewModel = ItemLibraryViewModel(parent: person)
        router.route(to: \.library, viewModel)
    }

    // MARK: layout

    private static func padLayout(libraryViewType: LibraryViewType, listColumnCount: Int) -> CollectionVGridLayout {
        switch libraryViewType {
        case .landscapeGrid:
            .minWidth(220)
        case .portraitGrid:
            .minWidth(150)
        case .list:
            .columns(listColumnCount, insets: .zero, itemSpacing: 0, lineSpacing: 0)
        }
    }

    private static func phoneLayout(libraryViewType: LibraryViewType) -> CollectionVGridLayout {
        switch libraryViewType {
        case .portraitGrid:
            .columns(3)
        case .landscapeGrid:
            .columns(2)
        case .list:
            .columns(1, insets: .zero, itemSpacing: 0, lineSpacing: 0)
        }
    }

    private func landscapeGridItemView(item: Element) -> some View {
        PosterButton(item: item, type: .landscape)
            .content {
                if item.showTitle {
                    PosterButton.TitleContentView(item: item)
                        .backport
                        .lineLimit(1, reservesSpace: true)
                }
            }
            .onSelect {
                onSelect(item)
            }
    }

    private func portraitGridItemView(item: Element) -> some View {
        PosterButton(item: item, type: .portrait)
            .content {
                if item.showTitle {
                    PosterButton.TitleContentView(item: item)
                        .backport
                        .lineLimit(1, reservesSpace: true)
                }
            }
            .onSelect {
                onSelect(item)
            }
    }

    private func listItemView(item: Element) -> some View {
        LibraryRow(item: item)
            .onSelect {
                onSelect(item)
            }
    }

    // MARK: innerBody

    @ViewBuilder
    private var innerBody: some View {
        switch viewModel.state {
        case let .error(jellyfinAPIError):
            Text(jellyfinAPIError.localizedDescription)
        case .refreshing:
            loadingView
        case .gettingNextPage, .gettingRandomItem, .items:
            if viewModel.items.isEmpty {
                noResultsView
            } else {
                libraryItemsView
            }
        }
    }

    private var libraryItemsView: some View {
        CollectionVGrid(
            $viewModel.items,
            layout: $layout
        ) { item in
            switch libraryViewType {
            case .landscapeGrid:
                landscapeGridItemView(item: item)
            case .portraitGrid:
                portraitGridItemView(item: item)
            case .list:
                listItemView(item: item)
            }
        }
        .onReachedBottomEdge(offset: 100) {
            viewModel.send(.getNextPage)
        }
        .refreshable {
            print("pulled to refresh")
            viewModel.send(.refresh)
        }
    }

    private var loadingView: some View {
        ProgressView()
    }

    private var noResultsView: some View {
        L10n.noResults.text
    }

    // MARK: body

    var body: some View {
        innerBody
            .ignoresSafeArea()
            .navigationTitle(viewModel.parent?.displayTitle ?? "")
            .navigationBarTitleDisplayMode(.inline)
//            .if(true) { view in
//                view.navBarDrawer {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        FilterDrawerHStack(viewModel: viewModel.filterViewModel, types: ItemFilterType.allCases)
//                            .onSelect {
//                                router.route(to: \.filter, $0)
//                            }
//                            .padding(.horizontal)
//                            .padding(.vertical, 1)
//                    }
//                }
//            }
            .onChange(of: libraryViewType) { newValue in
                if UIDevice.isPhone {
                    layout = Self.phoneLayout(libraryViewType: newValue)
                } else {
                    layout = Self.padLayout(libraryViewType: newValue, listColumnCount: listColumnCount)
                }
            }
            .onChange(of: listColumnCount) { newValue in
                if UIDevice.isPhone {
                    layout = Self.phoneLayout(libraryViewType: libraryViewType)
                } else {
                    layout = Self.padLayout(libraryViewType: libraryViewType, listColumnCount: newValue)
                }
            }
            .onChange(of: viewModel.randomItem) { item in
                guard let item else { return }

                switch item {
                case let item as BaseItemDto:
                    router.route(to: \.item, item)
                case let item as BaseItemPerson:
                    let viewModel = ItemLibraryViewModel(parent: item)
                    router.route(to: \.library, viewModel)
                default:
                    fatalError("Used an unexpected type within a `PagingLibaryView`?")
                }
            }
            .onFirstAppear {
                viewModel.send(.refresh)
            }
            .topBarTrailing {

                if viewModel.state == .gettingNextPage || viewModel.state == .gettingRandomItem {
                    ProgressView()
                }

                Menu {
                    LibraryViewTypeToggle(libraryViewType: $libraryViewType, listColumnCount: $listColumnCount)

                    RandomItemButton(viewModel: viewModel)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
    }
}
