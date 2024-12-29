//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

extension AddServerUserAccessTagsView {

    struct TagInput: View {

        // MARK: - Element Variables

        @Binding
        var access: Bool
        @Binding
        var tag: String

        let tagIsDuplicate: Bool
        let tagAlreadyExists: Bool

        // MARK: - Body

        var body: some View {
            tagView
        }

        // MARK: - Tag View

        @ViewBuilder
        private var tagView: some View {
            Section {
                Picker(L10n.access, selection: $access) {
                    Text(L10n.allowed).tag(true)
                    Text(L10n.blocked).tag(false)
                }
                // TODO: Enable on 10.10
                .disabled(true)
            } header: {
                Text(L10n.access)
            } footer: {
                LearnMoreButton(L10n.accessTags) {
                    TextPair(
                        title: L10n.allowed,
                        subtitle: L10n.accessTagAllowDescription
                    )
                    TextPair(
                        title: L10n.blocked,
                        subtitle: L10n.accessTagBlockDescription
                    )
                }
            }

            Section {
                TextField(L10n.name, text: $tag)
                    .autocorrectionDisabled()
            } footer: {
                if tag.isEmpty || tag == "" {
                    Label(
                        L10n.required,
                        systemImage: "exclamationmark.circle.fill"
                    )
                    .labelStyle(.sectionFooterWithImage(imageStyle: .orange))
                } else if tagIsDuplicate {
                    Label(
                        L10n.accessTagAlreadyExists,
                        systemImage: "exclamationmark.circle.fill"
                    )
                    .labelStyle(.sectionFooterWithImage(imageStyle: .orange))
                } else {
                    if tagAlreadyExists {
                        Label(
                            L10n.existsOnServer,
                            systemImage: "checkmark.circle.fill"
                        )
                        .labelStyle(.sectionFooterWithImage(imageStyle: .green))
                    } else {
                        Label(
                            L10n.willBeCreatedOnServer,
                            systemImage: "checkmark.seal.fill"
                        )
                        .labelStyle(.sectionFooterWithImage(imageStyle: .blue))
                    }
                }
            }
        }
    }
}
