//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Combine
import Foundation
import JellyfinAPI

class RefreshMetadataViewModel: ViewModel, Stateful, Eventful {

    // MARK: Events

    enum Event: Equatable {
        case error(JellyfinAPIError)
        case refreshTriggered(Date)
        case refreshCompleted
    }

    // MARK: Action

    enum Action: Equatable {
        case error(JellyfinAPIError)
        case refreshMetadata(
            metadataRefreshMode: MetadataRefreshMode,
            imageRefreshMode: MetadataRefreshMode,
            replaceMetadata: Bool = false,
            replaceImages: Bool = false
        )
    }

    // MARK: State

    enum State: Hashable {
        case content
        case error(JellyfinAPIError)
        case initial
        case refreshing
    }

    @Published
    private var item: BaseItemDto
    @Published
    final var state: State = .initial

    private var itemTask: AnyCancellable?
    private var eventSubject = PassthroughSubject<Event, Never>()

    var events: AnyPublisher<Event, Never> {
        eventSubject
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    // MARK: Init

    init(item: BaseItemDto) {
        self.item = item
        super.init()
    }

    // MARK: Respond

    func respond(to action: Action) -> State {
        switch action {
        case let .error(error):
            eventSubject.send(.error(error))
            return .error(error)

        case let .refreshMetadata(metadataRefreshMode, imageRefreshMode, replaceMetadata, replaceImages):
            itemTask?.cancel()

            itemTask = Task { [weak self] in
                guard let self = self else { return }
                do {
                    await MainActor.run {
                        self.state = .content
                        self.eventSubject.send(.refreshTriggered(Date()))
                    }

                    try await self.refreshMetadata(
                        metadataRefreshMode: metadataRefreshMode,
                        imageRefreshMode: imageRefreshMode,
                        replaceMetadata: replaceMetadata,
                        replaceImages: replaceImages
                    )

                    // Start polling for completion after triggering refresh
                    try await self.pollRefreshCompletion()

                    await MainActor.run {
                        self.state = .content
                        self.eventSubject.send(.refreshCompleted)
                    }
                } catch {
                    guard !Task.isCancelled else { return }

                    let apiError = JellyfinAPIError(error.localizedDescription)
                    await MainActor.run {
                        self.state = .error(apiError)
                        self.eventSubject.send(.error(apiError))
                    }
                }
            }
            .asAnyCancellable()

            return .refreshing
        }
    }

    // MARK: Metadata Refresh Logic

    private func refreshMetadata(
        metadataRefreshMode: MetadataRefreshMode,
        imageRefreshMode: MetadataRefreshMode,
        replaceMetadata: Bool = false,
        replaceImages: Bool = false
    ) async throws {
        guard let itemId = item.id else { return }

        let parameters = Paths.RefreshItemParameters(
            metadataRefreshMode: metadataRefreshMode,
            imageRefreshMode: imageRefreshMode,
            isReplaceAllMetadata: replaceMetadata,
            isReplaceAllImages: replaceImages
        )
        let request = Paths.refreshItem(
            itemID: itemId,
            parameters: parameters
        )
        _ = try await userSession.client.send(request)
    }

    // MARK: Poll Task Progress

    private func pollRefreshCompletion() async throws {
        guard let itemID = item.id else { return }

        while true {
            try await Task.sleep(nanoseconds: 2_000_000_000)

            let request = Paths.getItem(userID: userSession.user.id, itemID: itemID)
            let response = try await userSession.client.send(request)

            await MainActor.run {
                self.item = response.value
            }

            // TODO: Figure out how to poll metadata refreshing
            if true {
                await MainActor.run {
                    Notifications[.itemMetadataDidChange].post(object: item)
                }
                break
            }
        }
    }
}