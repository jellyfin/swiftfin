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

final class NextUpLibraryViewModel: PagingLibraryViewModel<BaseItemDto> {

    override func get(page: Int) async throws -> [BaseItemDto] {

        let parameters = parameters(for: page)
        let request = Paths.getNextUp(parameters: parameters)
        let response = try await userSession.client.send(request)

        return response.value.items ?? []
    }

    private func parameters(for page: Int) -> Paths.GetNextUpParameters {

        var parameters = Paths.GetNextUpParameters()
        parameters.limit = DefaultPageSize
        parameters.startIndex = page
        parameters.fields = ItemFields.MinimumFields
        parameters.enableUserData = true

        return parameters
    }

    func markPlayed(item: BaseItemDto) {
        Task {

            let request = Paths.markPlayedItem(
                userID: userSession.user.id,
                itemID: item.id!
            )
            let _ = try await userSession.client.send(request)

            try await refresh()
        }
    }
}
