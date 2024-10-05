//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

extension VideoPlayer.Overlay.ActionButtons {

    struct AspectFill: View {

        @Environment(\.isAspectFilled)
        @Binding
        private var isAspectFilled: Bool

        private var systemImage: String {
            if isAspectFilled {
                "arrow.down.right.and.arrow.up.left"
            } else {
                "arrow.up.left.and.arrow.down.right"
            }
        }

        var body: some View {
            Button(
                "Aspect Fill",
                systemImage: systemImage
            ) {
                isAspectFilled.toggle()
            }
            .transition(.opacity.combined(with: .scale).animation(.snappy))
            .id(isAspectFilled)
        }
    }
}
