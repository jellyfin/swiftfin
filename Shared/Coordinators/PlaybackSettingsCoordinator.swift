//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import JellyfinAPI
import Stinsen
import SwiftUI

final class PlaybackSettingsCoordinator: NavigationCoordinatable {

    let stack = NavigationStack(initial: \PlaybackSettingsCoordinator.start)

    @Root
    var start = makeStart
    @Route(.push)
    var videoPlayerSettings = makeVideoPlayerSettings
    @Route(.push)
    var mediaStreamInfo = makeMediaStreamInfo
    @Route(.push)
    var playbackInformation = makePlaybackInformation

    func makeVideoPlayerSettings() -> VideoPlayerSettingsCoordinator {
        VideoPlayerSettingsCoordinator()
    }

    @ViewBuilder
    func makeMediaStreamInfo(mediaStream: MediaStream) -> some View {
        MediaStreamInfoView(mediaStream: mediaStream)
    }

    @ViewBuilder
    func makePlaybackInformation() -> some View {
        PlaybackInformationView()
    }

    @ViewBuilder
    func makeStart() -> some View {
        PlaybackSettingsView()
    }
}
