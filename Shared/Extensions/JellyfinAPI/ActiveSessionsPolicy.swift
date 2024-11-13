//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Foundation

enum ActiveSessionsPolicy: Int, Displayable, CaseIterable {
    case unlimited = 0
    case custom = 1 // Default to 1 Active Session

    // MARK: - Display Title

    var displayTitle: String {
        switch self {
        case .unlimited:
            return L10n.unlimited
        case .custom:
            return L10n.custom
        }
    }

    // MARK: - Get Policy from a Bitrate (Int)

    static func from(rawValue: Int) -> ActiveSessionsPolicy {
        ActiveSessionsPolicy(rawValue: rawValue) ?? .custom
    }
}
