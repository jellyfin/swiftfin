//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import Factory
import JellyfinAPI
import SwiftUI

extension ServerUsersView {

    struct ServerUsersRow: View {

        @Injected(\.currentUserSession)
        private var userSession

        @Default(.accentColor)
        private var accentColor

        // MARK: - Environment Variables

        @Environment(\.colorScheme)
        private var colorScheme
        @Environment(\.isEditing)
        private var isEditing
        @Environment(\.isSelected)
        private var isSelected

        @CurrentDate
        private var currentDate: Date

        private let user: UserDto

        // MARK: - Actions

        private let onSelect: () -> Void
        private let onDelete: () -> Void

        // MARK: - User Status Mapping

        private var userActive: Bool {
            if let isDisabled = user.policy?.isDisabled {
                return !isDisabled
            } else {
                return false
            }
        }

        // MARK: - Initializer

        init(
            user: UserDto,
            onSelect: @escaping () -> Void,
            onDelete: @escaping () -> Void
        ) {
            self.user = user
            self.onSelect = onSelect
            self.onDelete = onDelete
        }

        // MARK: - Label Styling

        private var labelForegroundStyle: some ShapeStyle {
            guard isEditing else { return userActive ? .primary : .secondary }

            return isSelected ? .primary : .secondary
        }

        // MARK: - User Image View

        @ViewBuilder
        private var userImage: some View {
            ZStack {
                ImageView(user.profileImageSource(client: userSession!.client))
                    .pipeline(.Swiftfin.branding)
                    .placeholder { _ in
                        SystemImageContentView(systemName: "person.fill", ratio: 0.5)
                    }
                    .failure {
                        SystemImageContentView(systemName: "person.fill", ratio: 0.5)
                    }
                    .grayscale(userActive ? 0.0 : 1.0)

                if isEditing {
                    Color.black
                        .opacity(isSelected ? 0 : 0.5)
                }
            }
            .clipShape(.circle)
            .aspectRatio(1, contentMode: .fill)
            .posterShadow()
            .frame(width: 60, height: 60)
        }

        // MARK: - Row Content

        @ViewBuilder
        private var rowContent: some View {
            HStack {
                VStack(alignment: .leading) {

                    Text(user.name ?? L10n.unknown)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    TextPairView(
                        L10n.role,
                        value: {
                            if let isAdministrator = user.policy?.isAdministrator,
                               isAdministrator
                            {
                                Text(L10n.administrator)
                            } else {
                                Text(L10n.user)
                            }
                        }()
                    )

                    TextPairView(
                        L10n.lastSeen,
                        value: Text(user.lastActivityDate, format: .lastSeen)
                    )
                    .id(currentDate)
                    .monospacedDigit()
                }
                .font(.subheadline)
                .foregroundStyle(labelForegroundStyle, .secondary)

                Spacer()

                if isEditing, isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .backport
                        .fontWeight(.bold)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(accentColor.overlayColor, accentColor)

                } else if isEditing {
                    Image(systemName: "circle")
                        .resizable()
                        .backport
                        .fontWeight(.bold)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.secondary)
                }
            }
        }

        // MARK: - Body

        var body: some View {
            ListRow(insets: .init(horizontal: EdgeInsets.edgePadding)) {
                userImage
            } content: {
                rowContent
                    .padding(.vertical, 8)
            }
            .onSelect(perform: onSelect)
            .swipeActions {
                Button(
                    L10n.delete,
                    systemImage: "trash",
                    action: onDelete
                )
                .tint(.red)
            }
        }
    }
}