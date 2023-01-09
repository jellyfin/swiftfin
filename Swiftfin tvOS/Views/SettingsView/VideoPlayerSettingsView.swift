//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

struct VideoPlayerSettingsView: View {

    @Default(.VideoPlayer.Subtitle.subtitleFontName)
    private var subtitleFontName

    @Default(.VideoPlayer.jumpBackwardLength)
    private var jumpBackwardLength
    @Default(.VideoPlayer.jumpForwardLength)
    private var jumpForwardLength
    @Default(.VideoPlayer.resumeOffset)
    private var resumeOffset

    @EnvironmentObject
    private var router: VideoPlayerSettingsCoordinator.Router

    var body: some View {
        SplitFormWindowView()
            .descriptionView {
                Image(systemName: "tv")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 400)
            }
            .contentView {

                Section {} footer: {
                    Text("Resume content seconds before the recorded resume time")
                }

                Section {
                    ChevronButton(title: L10n.subtitleFont, subtitle: subtitleFontName)
                        .onSelect {
                            router.route(to: \.fontPicker, $subtitleFontName)
                        }
                } footer: {
                    Text("Settings only affect some subtitle types")
                }
            }
            .navigationTitle("Video Player")
    }
}