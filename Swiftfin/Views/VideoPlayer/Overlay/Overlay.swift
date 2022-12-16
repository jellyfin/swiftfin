//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI
import VLCUI

protocol VideoPlayerOverlay: View {}

extension EmptyView: VideoPlayerOverlay {}

extension VideoPlayer {

    struct Overlay: VideoPlayerOverlay {

        @Default(.VideoPlayer.Overlay.playbackButtonType)
        private var playbackButtonType

        @Environment(\.safeAreaInsets)
        private var safeAreaInsets

        @EnvironmentObject
        private var splitContentViewProxy: SplitContentViewProxy

        @Environment(\.currentOverlayType)
        @Binding
        private var currentOverlayType
        @Environment(\.isScrubbing)
        @Binding
        private var isScrubbing: Bool

        var body: some View {
            ZStack {
                VStack {
                    TopBarView()
                        .if(UIDevice.isPhone) { view in
                            view.padding(safeAreaInsets.mutating(\.trailing, to: 0))
                                .padding(.trailing, splitContentViewProxy.isPresentingSplitView ? 0 : safeAreaInsets.trailing)
                        }
                        .if(UIDevice.isIPad) { view in
                            view.padding(.top)
                                .padding2(.horizontal)
                        }
                        .background {
                            LinearGradient(
                                stops: [
                                    .init(color: .black.opacity(0.9), location: 0),
                                    .init(color: .clear, location: 1),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .opacity(playbackButtonType == .compact ? 1 : 0)
                        }
                        .opacity(!isScrubbing && currentOverlayType == .main ? 1 : 0)

                    Spacer()
                        .allowsHitTesting(false)

                    BottomBarView()
                        .if(UIDevice.isPhone) { view in
                            view.padding(safeAreaInsets.mutating(\.trailing, to: 0))
                                .padding(.trailing, splitContentViewProxy.isPresentingSplitView ? 0 : safeAreaInsets.trailing)
                        }
                        .if(UIDevice.isIPad) { view in
                            view.padding2(.bottom)
                                .padding2(.horizontal)
                        }
                        .background {
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0),
                                    .init(color: .black.opacity(0.5), location: 0.5),
                                    .init(color: .black.opacity(0.5), location: 1),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .opacity(isScrubbing || playbackButtonType == .compact ? 1 : 0)
                        }
                        .opacity(isScrubbing || currentOverlayType == .main ? 1 : 0)
                }

                if playbackButtonType == .large {
                    LargePlaybackButtons()
                        .opacity(!isScrubbing && currentOverlayType == .main ? 1 : 0)
                }
            }
            .background {
                Color.black
                    .opacity(!isScrubbing && playbackButtonType == .large && currentOverlayType == .main ? 0.5 : 0)
                    .allowsHitTesting(false)
            }
            .animation(.linear(duration: 0.1), value: isScrubbing)
        }
    }
}
