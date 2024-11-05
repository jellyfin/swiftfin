//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Combine
import JellyfinAPI
import SwiftUI

extension EditMetadataView {
    struct LockMetadataSection: View {
        @Binding
        var item: BaseItemDto

        var body: some View {
            Section(L10n.lockedFields) {
                Toggle(L10n.lockAllFields, isOn: Binding(get: {
                    item.lockData ?? false
                }, set: {
                    item.lockData = $0
                }))
            }

            if item.lockData != true {
                ForEach(MetadataField.allCases, id: \.self) { field in
                    Toggle(field.displayTitle, isOn: Binding(
                        get: { item.lockedFields?.contains(field) == nil },
                        set: { isSelected in
                            if isSelected {
                                item.lockedFields?.removeAll { $0 == field }
                            } else {
                                item.lockedFields?.append(field)
                            }
                        }
                    ))
                }
            }
        }
    }
}