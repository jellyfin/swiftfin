//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Defaults
import JellyfinAPI
import SwiftUI

struct MovieItemView: View {

    @EnvironmentObject
    private var viewModel: ItemViewModel
    @Default(.itemViewType)
    private var itemViewType

	var body: some View {
        switch itemViewType {
        case .compactPoster:
            ItemView.CompactPosterScrollView {
                ContentView()
                    .environmentObject(viewModel)
            }
        case .compactLogo:
            ItemView.CompactLogoScrollView {
                ContentView()
                    .environmentObject(viewModel)
            }
        case .cinematic:
            ItemView.CinematicScrollView {
                ContentView()
                    .environmentObject(viewModel)
            }
        }
	}
}
