//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Combine
import CoreStore
import Factory
import JellyfinAPI
import OrderedCollections

// TODO: transition to `Stateful`
final class HomeViewModel: ViewModel {

    @Published
    var libraries: [LatestInLibraryViewModel] = [] {
        didSet {
            for library in libraries {
                Task {
                    try await library.refresh()
                }
                .asAnyCancellable()
                .store(in: &cancellables)
            }
        }
    }

    @Published
    var resumeItems: OrderedSet<BaseItemDto> = []

    var nextUpViewModel: NextUpLibraryViewModel = .init()
    var recentlyAddedViewModel: RecentlyAddedLibraryViewModel = .init()

    override init() {
        super.init()

        Task {
            await refresh()
        }
    }

    @objc
    func refresh() async {

        logger.debug("Refreshing home screen")

        await MainActor.run {
            isLoading = true
            libraries = []
            resumeItems = []
        }

        refreshResumeItems()

        Task {
            try await nextUpViewModel.refresh()
        }
        .asAnyCancellable()
        .store(in: &cancellables)

        Task {
            try await recentlyAddedViewModel.refresh()
        }
        .asAnyCancellable()
        .store(in: &cancellables)

        do {
            try await refreshLibrariesLatest()
        } catch {
            await MainActor.run {
                libraries = []
                isLoading = false
                self.error = .init(message: error.localizedDescription)
            }

            return
        }

        await MainActor.run {
            self.error = nil
            isLoading = false
        }
    }

    // MARK: Libraries Latest Items

    private func refreshLibrariesLatest() async throws {
        let userViewsPath = Paths.getUserViews(userID: userSession.user.id)
        let response = try await userSession.client.send(userViewsPath)

        guard let allLibraries = response.value.items else {
            await MainActor.run {
                libraries = []
            }

            return
        }

        let excludedLibraryIDs = await getExcludedLibraries()

        let newLibraries = allLibraries
            .intersection(["movies", "tvshows"], using: \.collectionType)
            .subtracting(excludedLibraryIDs, using: \.id)
            .map { LatestInLibraryViewModel(parent: $0) }

        await MainActor.run {
            libraries = newLibraries
        }
    }

    private func getExcludedLibraries() async -> [String] {
        let currentUserPath = Paths.getCurrentUser
        let response = try? await userSession.client.send(currentUserPath)

        return response?.value.configuration?.latestItemsExcludes ?? []
    }

    // MARK: Resume Items

    private func refreshResumeItems() {
        Task {
            let resumeParameters = Paths.GetResumeItemsParameters(
                limit: 20,
                fields: ItemFields.MinimumFields,
                enableUserData: true,
                includeItemTypes: [.movie, .episode]
            )

            let request = Paths.getResumeItems(userID: userSession.user.id, parameters: resumeParameters)
            let response = try await userSession.client.send(request)

            guard let items = response.value.items else { return }

            await MainActor.run {
                resumeItems = OrderedSet(items)
            }
        }
    }

    func markItemUnplayed(_ item: BaseItemDto) {
        guard resumeItems.contains(where: { $0.id == item.id! }) else { return }

        Task {
            let request = Paths.markUnplayedItem(
                userID: userSession.user.id,
                itemID: item.id!
            )
            let _ = try await userSession.client.send(request)

            refreshResumeItems()

            try await nextUpViewModel.refresh()
            try await recentlyAddedViewModel.refresh()
        }
    }

    func markItemPlayed(_ item: BaseItemDto) {
        guard resumeItems.contains(where: { $0.id == item.id! }) else { return }

        Task {
            let request = Paths.markPlayedItem(
                userID: userSession.user.id,
                itemID: item.id!
            )
            let _ = try await userSession.client.send(request)

            refreshResumeItems()
            try await nextUpViewModel.refresh()
            try await recentlyAddedViewModel.refresh()
        }
    }
}
