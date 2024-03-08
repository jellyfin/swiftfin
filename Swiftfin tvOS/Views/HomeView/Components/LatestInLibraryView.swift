//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

extension HomeView {

    struct LatestInLibraryView: View {

        @EnvironmentObject
        private var router: HomeCoordinator.Router

        @ObservedObject
        var viewModel: LatestInLibraryViewModel

        var body: some View {
            if viewModel.items.isNotEmpty {
                PosterHStack(
                    title: L10n.latestWithString(viewModel.parent?.displayTitle ?? .emptyDash),
                    type: .portrait,
                    items: viewModel.items.prefix(20).asArray
                )
                //            .trailing {
                //                SeeAllPosterButton(type: .portrait)
                //                    .onSelect {
                //                        router.route(
                //                            to: \.basicLibrary,
                //                            .init(
                //                                title: L10n.latestWithString(viewModel.parent.displayTitle),
                //                                viewModel: viewModel
                //                            )
                //                        )
                //                    }
                //            }
                    .onSelect { item in
                        router.route(to: \.item, item)
                    }
            }
        }
    }
}
