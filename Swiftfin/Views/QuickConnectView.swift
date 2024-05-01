//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

struct QuickConnectView: View {

    @EnvironmentObject
    private var router: UserSignInCoordinator.Router

    @ObservedObject
    private var viewModel: QuickConnect

    init(quickConnect: QuickConnect) {
        self.viewModel = quickConnect
    }

    private func pollingView(code: String) -> some View {
        VStack(spacing: 50) {

            #warning("TODO: finalize, probably move back to steps")
            Text("Enter the following code on another Jellyfin login:")

            Text(code)
                .tracking(10)
                .font(.largeTitle)
                .monospacedDigit()

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .edgePadding()
    }

    var body: some View {
        WrappedView {
            switch viewModel.state {
            case .idle, .authenticated:
                Color.clear
            case .retrievingCode:
                ProgressView()
            case let .polling(code):
                pollingView(code: code)
            case let .error(error):
                ErrorView(error: error)
            }
        }
        .edgePadding()
        .navigationTitle(L10n.quickConnect)
        .navigationBarTitleDisplayMode(.inline)
        .onFirstAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .navigationBarCloseButton {
            router.popLast()
        }
    }
}
