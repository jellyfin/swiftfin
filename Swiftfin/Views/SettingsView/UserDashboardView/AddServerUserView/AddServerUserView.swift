//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Combine
import Defaults
import JellyfinAPI
import SwiftUI

struct AddServerUserView: View {

    private enum Field: Hashable {
        case username
        case password
        case confirmPassword
    }

    @Default(.accentColor)
    private var accentColor

    @EnvironmentObject
    private var router: BasicNavigationViewCoordinator.Router

    @FocusState
    private var focusedfield: Field?

    @State
    private var username: String = ""
    @State
    private var password: String = ""
    @State
    private var confirmPassword: String = ""

    @State
    private var error: Error?
    @State
    private var isPresentingError: Bool = false
    @State
    private var isPresentingSuccess: Bool = false

    @StateObject
    private var viewModel = AddServerUserViewModel()

    private var isValid: Bool {
        username.isNotEmpty && password == confirmPassword
    }

    var body: some View {
        List {

            Section {
                TextField(L10n.username, text: $username) {
                    focusedfield = .password
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .focused($focusedfield, equals: .username)
                .disabled(viewModel.state == .creatingUser)
            } header: {
                Text(L10n.username)
            } footer: {
                if username.isEmpty {
                    Label(L10n.usernameRequired, systemImage: "exclamationmark.circle.fill")
                        .labelStyle(.sectionFooterWithImage(imageStyle: .orange))
                }
            }

            Section(L10n.password) {
                UnmaskSecureField(L10n.password, text: $password) {
                    focusedfield = .confirmPassword
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .focused($focusedfield, equals: .password)
                .disabled(viewModel.state == .creatingUser)
            }

            Section {
                UnmaskSecureField(L10n.confirmPassword, text: $confirmPassword) {}
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.none)
                    .focused($focusedfield, equals: .confirmPassword)
                    .disabled(viewModel.state == .creatingUser)
            } header: {
                Text(L10n.confirmPassword)
            } footer: {
                if password != confirmPassword {
                    Label(L10n.passwordsDoNotMatch, systemImage: "exclamationmark.circle.fill")
                        .labelStyle(.sectionFooterWithImage(imageStyle: .orange))
                }
            }
        }
        .animation(.linear(duration: 0.2), value: isValid)
        .interactiveDismissDisabled(viewModel.state == .creatingUser)
        .navigationTitle(L10n.newUser)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarCloseButton {
            router.dismissCoordinator()
        }
        .onFirstAppear {
            focusedfield = .username
        }
        .onReceive(viewModel.events) { event in
            switch event {
            case let .error(eventError):
                UIDevice.feedback(.error)

                error = eventError
                isPresentingError = true
            case let .createdNewUser(newUser):
                UIDevice.feedback(.success)
                router.dismissCoordinator()
                Notifications[.didAddServerUser].post(object: newUser)
            }
        }
        .topBarTrailing {
            if viewModel.state == .creatingUser {
                ProgressView()
            }

            if viewModel.state == .creatingUser {
                Button(L10n.cancel) {
                    viewModel.send(.cancel)
                }
                .buttonStyle(.toolbarPill(.red))
            } else {
                Button(L10n.save) {
                    viewModel.send(.createUser(username: username, password: password))
                }
                .buttonStyle(.toolbarPill)
                .disabled(!isValid)
            }
        }
        .alert(
            L10n.error,
            isPresented: $isPresentingError,
            presenting: error
        ) { _ in
            Button(L10n.dismiss, role: .cancel) {
                focusedfield = .username
            }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}
