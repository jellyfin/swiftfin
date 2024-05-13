//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Foundation
import JellyfinAPI
import Stinsen
import SwiftUI

final class UserSignInCoordinator: NavigationCoordinatable {

    struct SecurityParameters {
        let pinHint: Binding<String>
        let signInPolicy: Binding<UserAccessPolicy>
    }

    let stack = NavigationStack(initial: \UserSignInCoordinator.start)

    @Root
    var start = makeStart

    #if os(iOS)
    @Route(.modal)
    var quickConnect = makeQuickConnect
    @Route(.modal)
    var security = makeSecurity
    #endif

    private let server: ServerState

    init(server: ServerState) {
        self.server = server
    }

    #if os(iOS)
    func makeQuickConnect(quickConnect: QuickConnect) -> NavigationViewCoordinator<BasicNavigationViewCoordinator> {
        NavigationViewCoordinator {
            QuickConnectView(quickConnect: quickConnect)
        }
    }

    func makeSecurity(parameters: SecurityParameters) -> NavigationViewCoordinator<BasicNavigationViewCoordinator> {
        NavigationViewCoordinator {
            UserSignInView.SecurityView(
                pinHint: parameters.pinHint,
                signInPolicy: parameters.signInPolicy
            )
        }
    }
    #endif

    @ViewBuilder
    func makeStart() -> some View {
        UserSignInView(server: server)
    }
}
