//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

struct VideoPlayerSettingsView: View {

    @Default(.VideoPlayer.autoPlay)
    private var autoPlay
    @Default(.VideoPlayer.jumpBackwardLength)
    private var jumpBackwardLength
    @Default(.VideoPlayer.jumpForwardLength)
    private var jumpForwardLength
    @Default(.VideoPlayer.playNextItem)
    private var playNextItem
    @Default(.VideoPlayer.playPreviousItem)
    private var playPreviousItem
    @Default(.VideoPlayer.resumeOffset)
    private var resumeOffset

    @Default(.VideoPlayer.Subtitle.subtitleFontName)
    private var subtitleFontName
    @Default(.VideoPlayer.Subtitle.subtitleSize)
    private var subtitleSize

    @Default(.VideoPlayer.Overlay.chapterSlider)
    private var chapterSlider
    @Default(.VideoPlayer.Overlay.playbackButtonType)
    private var playbackButtonType
    @Default(.VideoPlayer.Overlay.sliderColor)
    private var sliderColor
    @Default(.VideoPlayer.Overlay.sliderType)
    private var sliderType

    @Default(.VideoPlayer.Overlay.trailingTimestampType)
    private var trailingTimestampType
    @Default(.VideoPlayer.Overlay.showCurrentTimeWhileScrubbing)
    private var showCurrentTimeWhileScrubbing
    @Default(.VideoPlayer.Overlay.timestampType)
    private var timestampType

    @EnvironmentObject
    private var router: VideoPlayerSettingsCoordinator.Router

    var body: some View {
        Form {

            EnumPicker(title: L10n.jumpBackwardLength, selection: $jumpBackwardLength)

            EnumPicker(title: L10n.jumpForwardLength, selection: $jumpForwardLength)

            Section {
                Stepper(value: $resumeOffset, in: 0 ... 30) {
                    HStack {
                        Text("Resume Offset")
                        
                        Spacer()

                        Text("\(resumeOffset)")
                            .foregroundColor(.secondary)
                    }
                }
            } footer: {
                Text("Resume content seconds before the recorded resume time")
            }

            Section("Buttons") {

                EnumPicker(title: "Playback Buttons", selection: $playbackButtonType)

                Toggle(isOn: $autoPlay) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        L10n.autoPlay.text
                    }
                }

                Toggle(isOn: $playNextItem) {
                    HStack {
                        Image(systemName: "chevron.left.circle")
                        Text("Next Item")
                    }
                }

                Toggle(isOn: $playPreviousItem) {
                    HStack {
                        Image(systemName: "chevron.right.circle")
                        Text("Previous Item")
                    }
                }
            }

            Section("Slider") {

                Toggle("Chapter Slider", isOn: $chapterSlider)

                ColorPicker(selection: $sliderColor, supportsOpacity: false) {
                    Text("Slider Color")
                }

                EnumPicker(title: "Slider Type", selection: $sliderType)
            }
            
            Section("Subtitle") {

                ChevronButton(title: L10n.subtitleFont, subtitle: subtitleFontName)
                    .onSelect {
                        router.route(to: \.fontPicker)
                    }

                Stepper(value: $subtitleSize, in: 8 ... 24) {
                    HStack {
                        L10n.subtitleSize.text
                        
                        Spacer()

                        Text("\(subtitleSize)")
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section("Timestamp") {

                Toggle("Scrub Current Time", isOn: $showCurrentTimeWhileScrubbing)

                EnumPicker(title: "Timestamp Type", selection: $timestampType)
                
                EnumPicker(title: "Trailing Value", selection: $trailingTimestampType)
            }
        }
    }
}

struct VideoPlayerSettingsView_Preview: PreviewProvider {
    
    static var previews: some View {
        VideoPlayerSettingsView()
    }
}
