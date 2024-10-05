//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import AVFoundation
import Combine
import Defaults
import Factory
import Foundation
import JellyfinAPI
import MediaPlayer
import UIKit
import VLCUI

// TODO: proper error catching
// TODO: better solution for previous/next/queuing
// TODO: should view models handle progress reports instead, with a protocol
//       for other types of media handling

protocol MediaPlayerListener {

    var manager: MediaPlayerManager? { get set }

//    func itemDidChange(newItem: MediaPlayerItem)
//    func secondsDidChange(newSeconds: TimeInterval)
//    func stateDidChange(newState: MediaPlayerManager.State)
}

// TODO: queue provider
class MediaPlayerManager: ViewModel, Eventful, Stateful {

    enum Event {
        case playbackStopped
        case playNew(playbackItem: MediaPlayerItem)
    }

    enum Action: Equatable {

        case error(JellyfinAPIError)

        case pause
        case play
        case buffer
        case ended
        case stop

        case playNew(item: BaseItemDto, mediaSource: MediaSourceInfo)

        case seek(seconds: Int)
    }

    enum State: Hashable {
        case initial
        case loadingItem
        case error(JellyfinAPIError)

        case playing
        case paused
        case buffering
        case stopped
    }

    @Published
    private(set) var playbackItem: MediaPlayerItem? = nil

    @Published
    private(set) var item: BaseItemDto
//    @Published
    private(set) var progress: ProgressBoxValue = .init(progress: 0, seconds: 0)
    @Published
    private(set) var queue: [BaseItemDto] = []
    @Published
    private(set) var playbackSpeed: PlaybackSpeed = .one

    @Published
    final var state: State = .initial

//    @Published
    final var lastAction: Action? = nil

    var events: AnyPublisher<Event, Never> {
        eventSubject
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    private let eventSubject: PassthroughSubject<Event, Never> = .init()

    // proxy for the underlying video playing layer
    var proxy: MediaPlayerProxy!
    var itemBuildTask: AnyCancellable?

    var listeners: [any MediaPlayerListener] = []

    // MARK: init

    init(item: BaseItemDto, mediaItemProvider: @escaping () async throws -> MediaPlayerItem) {
        self.item = item
        super.init()

        // TODO: don't build on init
        buildMediaItem(from: mediaItemProvider)
    }

    init(playbackItem: MediaPlayerItem) {
        item = playbackItem.baseItem
        super.init()

        self.playbackItem = playbackItem
        queue.append(playbackItem.baseItem)

        state = .buffering
    }

    @MainActor
    func respond(to action: Action) -> State {

        guard state != .stopped else { return .stopped }

        switch action {
        case let .error(error):
            return .error(error)
        case .pause:

            return .paused
        case .play:

            return .playing
        case .buffer:
            return .buffering
        case .ended:
            // TODO: go next in queue
            return .loadingItem
        case .stop:
            Task { @MainActor in
                eventSubject.send(.playbackStopped)
            }
            return .stopped
//        case let .playNew(item: item, mediaSource: mediaSource):
        case .playNew:

            return .buffering
        case let .seek(seconds: seconds):

            progress = .init(
                progress: CGFloat(seconds) / CGFloat(item.runTimeSeconds),
                seconds: seconds
            )

            return state
        }
    }

    private func buildMediaItem(from provider: @escaping () async throws -> MediaPlayerItem) {
        itemBuildTask?.cancel()

        itemBuildTask = Task { [weak self] in
            do {

                await MainActor.run { [weak self] in
                    self?.state = .loadingItem
                }

                let playbackItem = try await provider()

                guard let self else { return }

                await MainActor.run {
                    self.state = .buffering
                    self.playbackItem = playbackItem
                    self.eventSubject.send(.playNew(playbackItem: playbackItem))
                }
            } catch {
                guard let self, !Task.isCancelled else { return }

                await MainActor.run {
                    self.send(.error(.init(error.localizedDescription)))
                }
            }
        }
        .asAnyCancellable()
    }
}

// MARK: OLD

extension MediaPlayerManager {

    // MARK: onTicksUpdated

//    func onTicksUpdated(ticks: Int, playbackInformation: VLCVideoPlayer.PlaybackInformation) {
//        if audioTrackIndex != playbackInformation.currentAudioTrack.index {
//            audioTrackIndex = playbackInformation.currentAudioTrack.index
//        }
//
//        if subtitleTrackIndex != playbackInformation.currentSubtitleTrack.index {
//            subtitleTrackIndex = playbackInformation.currentSubtitleTrack.index
//        }
//
//        nowPlayable.handleNowPlayablePlaybackChange(
//            playing: true,
//            metadata: .init(
//                rate: Float(playbackSpeed.rawValue),
//                position: Float(currentProgressHandler.seconds),
//                duration: Float(currentViewModel.item.runTimeSeconds)
//            )
//        )
//    }

    // MARK: onStateUpdated

//    func getAdjacentEpisodes(for item: BaseItemDto) {
//        Task { @MainActor in
//            guard let seriesID = item.seriesID, item.type == .episode else { return }
//
//            let parameters = Paths.GetEpisodesParameters(
//                userID: userSession.user.id,
//                fields: .MinimumFields,
//                adjacentTo: item.id!,
//                limit: 3
//            )
//            let request = Paths.getEpisodes(seriesID: seriesID, parameters: parameters)
//            let response = try await userSession.client.send(request)
//
//            // 4 possible states:
//            //  1 - only current episode
//            //  2 - two episodes with next episode
//            //  3 - two episodes with previous episode
//            //  4 - three episodes with current in middle
//
//            // 1
//            guard let items = response.value.items, items.count > 1 else { return }
//
//            var previousItem: BaseItemDto?
//            var nextItem: BaseItemDto?
//
//            if items.count == 2 {
//                if items[0].id == item.id {
//                    // 2
//                    nextItem = items[1]
//
//                } else {
//                    // 3
//                    previousItem = items[0]
//                }
//            } else {
//                nextItem = items[2]
//                previousItem = items[0]
//            }
//
//            var nextViewModel: VideoPlayerViewModel?
//            var previousViewModel: VideoPlayerViewModel?
//
//            if let nextItem, let nextItemMediaSource = nextItem.mediaSources?.first {
//                nextViewModel = try await nextItem.videoPlayerViewModel(with: nextItemMediaSource)
//            }
//
//            if let previousItem, let previousItemMediaSource = previousItem.mediaSources?.first {
//                previousViewModel = try await previousItem.videoPlayerViewModel(with: previousItemMediaSource)
//            }
//
//            await MainActor.run {
//                self.nextViewModel = nextViewModel
//                self.previousViewModel = previousViewModel
//            }
//        }
//    }

    // MARK: reports

    // MARK: commands

//    private func handleCommand(command: NowPlayableCommand, event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
//        switch command {
//        case .togglePausePlay:
//            if state == .playing {
//                proxy.pause()
//            } else {
//                proxy.play()
//            }
//        case .play:
//            proxy.play()
//        case .pause:
//            proxy.pause()
//        case .skipForward:
//            proxy.jumpForward(15)
//        case .skipBackward:
//            proxy.jumpBackward(15)
//        case .changePlaybackPosition:
//            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
//            proxy.setTime(event.positionTime)
    ////        case .nextTrack:
    ////            selectNextViewModel()
    ////        case .previousTrack:
    ////            selectPreviousViewModel()
//        default: ()
//        }
//
//        return .success
//    }
}
