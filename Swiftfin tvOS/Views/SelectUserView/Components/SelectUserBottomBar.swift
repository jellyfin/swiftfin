//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import SwiftUI

extension SelectUserView {

    struct SelectUserBottomBar: View {

        @Binding
        private var isEditing: Bool

        @Binding
        private var serverSelection: SelectUserServerSelection

        @EnvironmentObject
        private var router: SelectUserCoordinator.Router

        @ObservedObject
        private var viewModel: SelectUserViewModel

        private let areUsersSelected: Bool
        private let userCount: Int

        private let onDelete: () -> Void
        private let toggleAllUsersSelected: () -> Void

        // MARK: - Advanced Menu

        @ViewBuilder
        private var advancedMenu: some View {
            Menu {
                Button(L10n.editUsers, systemImage: "person.crop.circle") {
                    isEditing.toggle()
                }
                // TODO: Advanced settings on tvOS?
                //
                // Divider()
                //
                // Button(L10n.advanced, systemImage: "gearshape.fill") {
                //     router.route(to: \.advancedSettings)
                // }
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.primary)
                    .frame(width: 50, height: 50)
            }
            .accessibilityLabel(L10n.advanced)

            // TODO: Do we want to support a grid view and list view like iOS?
//            if !viewModel.servers.isEmpty {
//                Picker(selection: $userListDisplayType) {
//                    ForEach(LibraryDisplayType.allCases, id: \.hashValue) {
//                        Label($0.displayTitle, systemImage: $0.systemImage)
//                            .tag($0)
//                    }
//                } label: {
//                    Text(L10n.layout)
//                    Text(userListDisplayType.displayTitle)
//                    Image(systemName: userListDisplayType.systemImage)
//                }
//                .pickerStyle(.menu)
//            }
        }

        // MARK: - Add User Button

        @ViewBuilder
        private var addUserButton: some View {
            Menu {
                ForEach(viewModel.servers.keys, id: \.self) { server in
                    Button(server.name, systemImage: "person.crop.circle.fill.badge.plus") {
                        router.route(to: \.userSignIn, server)
                    }
                }
            } label: {
                Image(systemName: "person.fill.badge.plus")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.primary)
                    .frame(width: 50, height: 50)
            }
            .accessibilityLabel(L10n.addUser)
        }

        // MARK: - Delete User Button

        private var deleteUsersButton: some View {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Text(L10n.delete)
                    .foregroundStyle(areUsersSelected ? Color.primary : Color.secondary)
                    .font(.body.weight(.semibold))
                    .frame(width: 400, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .opacity(areUsersSelected ? 1.0 : 0.5)
            .disabled(!areUsersSelected)
        }

        // MARK: - Initializer

        init(
            isEditing: Binding<Bool>,
            serverSelection: Binding<SelectUserServerSelection>,
            areUsersSelected: Bool,
            viewModel: SelectUserViewModel,
            userCount: Int,
            onDelete: @escaping () -> Void,
            toggleAllUsersSelected: @escaping () -> Void
        ) {
            self._isEditing = isEditing
            self._serverSelection = serverSelection
            self.viewModel = viewModel
            self.areUsersSelected = areUsersSelected
            self.userCount = userCount
            self.onDelete = onDelete
            self.toggleAllUsersSelected = toggleAllUsersSelected
        }

        // MARK: - Content View

        @ViewBuilder
        private var contentView: some View {
            HStack(alignment: .center) {
                if isEditing {
                    deleteUsersButton

                    Button {
                        toggleAllUsersSelected()
                    } label: {
                        Text(areUsersSelected ? L10n.removeAll : L10n.selectAll)
                            .foregroundStyle(Color.primary)
                            .font(.body.weight(.semibold))
                            .frame(width: 200, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Button {
                        isEditing = false
                    } label: {
                        Text(L10n.cancel)
                            .foregroundStyle(Color.primary)
                            .font(.body.weight(.semibold))
                            .frame(width: 200, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                } else {
                    addUserButton

                    ServerSelectionMenu(
                        selection: $serverSelection,
                        viewModel: viewModel
                    )

                    advancedMenu
                }
            }
        }

        // MARK: - Body

        var body: some View {
            // `Menu` with custom label has some weird additional
            // frame/padding that differs from default label style
            AlternateLayoutView(alignment: .top) {
                Color.clear
                    .frame(height: 100)
            } content: {
                contentView
            }
        }
    }
}
