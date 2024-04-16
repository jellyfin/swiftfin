//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import SwiftUI

// TODO: background refresh for programs with timer?
// TODO: no programs view

struct LiveTVProgramsView: View {

//    @EnvironmentObject
//    private var router: LiveTVCoordinator.Router

    @StateObject
    private var programsViewModel = LiveTVProgramsViewModel()

    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                if programsViewModel.recommended.isNotEmpty {
                    programsSection(title: L10n.onNow, keyPath: \.recommended)
                }

                if programsViewModel.series.isNotEmpty {
                    programsSection(title: L10n.series, keyPath: \.series)
                }

                if programsViewModel.movies.isNotEmpty {
                    programsSection(title: L10n.movies, keyPath: \.movies)
                }

                if programsViewModel.kids.isNotEmpty {
                    programsSection(title: L10n.kids, keyPath: \.kids)
                }

                if programsViewModel.sports.isNotEmpty {
                    programsSection(title: L10n.sports, keyPath: \.sports)
                }

                if programsViewModel.news.isNotEmpty {
                    programsSection(title: L10n.news, keyPath: \.news)
                }
            }
        }
    }

    @ViewBuilder
    private func programsSection(
        title: String,
        keyPath: KeyPath<LiveTVProgramsViewModel, [BaseItemDto]>
    ) -> some View {
        PosterHStack(
            title: title,
            type: .landscape,
            items: programsViewModel[keyPath: keyPath]
        )
        .content(ProgramButtonContent.init)
        .imageOverlay(ProgramProgressOverlay.init)
    }

    var body: some View {
        WrappedView {
            switch programsViewModel.state {
            case .content:
                contentView
            case let .error(error):
                Text(error.localizedDescription)
            case .initial, .refreshing:
                ProgressView()
            }
        }
        .ignoresSafeArea(edges: [.bottom, .horizontal])
        .onFirstAppear {
            if programsViewModel.state == .initial {
                programsViewModel.send(.refresh)
            }
        }
    }
}