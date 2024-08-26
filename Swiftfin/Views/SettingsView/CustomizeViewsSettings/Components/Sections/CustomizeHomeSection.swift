//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

extension CustomizeViewsSettings {
    struct CustomizeHomeSection: View {

        @Default(.Customization.Home.showRecentlyAdded)
        private var showRecentlyAdded
        @Default(.Customization.Home.maxNextUp)
        private var maxNextUp
        @Default(.Customization.Home.enableRewatching)
        private var enableRewatching

        var body: some View {
            Section {
                Toggle(L10n.showRecentlyAdded, isOn: $showRecentlyAdded)
                Toggle(L10n.nextUpRewatch, isOn: $enableRewatching)
                BasicStepper(
                    title: L10n.nextUpDays,
                    value: $maxNextUp,
                    range: 0 ... 999,
                    step: 1
                )
                .valueFormatter { days in
                    switch days {
                    case 0:
                        return L10n.disabled
                    case 1:
                        return "1 " + L10n.day
                    default:
                        return "\(days) " + L10n.days
                    }
                }
            } header: {
                L10n.home.text
            } footer: {
                L10n.nextUpDaysDescription.text
            }
        }
    }
}
