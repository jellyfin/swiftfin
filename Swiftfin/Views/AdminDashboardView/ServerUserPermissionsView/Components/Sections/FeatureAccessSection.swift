//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

extension ServerUserPermissionsView {

    struct FeatureAccessSection: View {

        @Binding
        var policy: UserPolicy

        var body: some View {
            Section(L10n.featureAccess) {
                Toggle(L10n.liveTvAccess, isOn: Binding(
                    get: { policy.enableLiveTvAccess ?? false },
                    set: { policy.enableLiveTvAccess = $0 }
                ))

                Toggle(L10n.liveTvRecordingManagement, isOn: Binding(
                    get: { policy.enableLiveTvManagement ?? false },
                    set: { policy.enableLiveTvManagement = $0 }
                ))
            }
        }
    }
}
