//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI
import SwiftUIIntrospect

extension View {

    @ViewBuilder
    func navigationBarBranding(
        isLoading: Bool?
    ) -> some View {
        modifier(
            NavigationBarBrandingModifier(
                isLoading: isLoading
            )
        )
    }
}
