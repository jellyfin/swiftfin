//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI
import Stinsen
import SwiftUI

final class ItemVideoPlayerCoordinator: NavigationCoordinatable {

    let stack = NavigationStack(initial: \ItemVideoPlayerCoordinator.start)

    @Root
    var start = makeStart

    let viewModel: ItemVideoPlayerViewModel

    init(viewModel: ItemVideoPlayerViewModel) {
        self.viewModel = viewModel
    }

    @ViewBuilder
    func makeStart() -> some View {
        ItemVideoPlayer(viewModel: viewModel)
            .prefersHomeIndicatorAutoHidden(true)
    }
}
