//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

extension ButtonStyle where Self == ToolbarPillButtonStyle {

    static var toolbarPill: ToolbarPillButtonStyle {
        ToolbarPillButtonStyle()
    }
}

struct ToolbarPillButtonStyle: ButtonStyle {

    @Default(.accentColor)
    private var accentColor

    @Environment(\.isEnabled)
    private var isEnabled

    private var foregroundStyle: some ShapeStyle {
        if isEnabled {
            accentColor.overlayColor
        } else {
            Color.secondary.overlayColor
        }
    }

    private var background: some ShapeStyle {
        if isEnabled {
            accentColor
        } else {
            Color.secondary
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foregroundStyle)
            .font(.headline)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(isEnabled && !configuration.isPressed ? 1 : 0.5)
    }
}

extension ButtonStyle where Self == OnPressButtonStyle {

    static func onPress(perform action: @escaping (Bool) -> Void) -> OnPressButtonStyle {
        OnPressButtonStyle(onPress: action)
    }
}

struct OnPressButtonStyle: ButtonStyle {

    var onPress: (Bool) -> Void

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                onPress(newValue)
            }
    }
}

extension ButtonStyle where Self == VideoPlayerBarButtonStyle {

    static func videoPlayerBarButton(perform action: @escaping (Bool) -> Void) -> VideoPlayerBarButtonStyle {
        VideoPlayerBarButtonStyle(onPress: action)
    }
}

struct VideoPlayerBarButtonStyle: ButtonStyle {

    @State
    private var onTapIsPressed = false

    var onPress: (Bool) -> Void

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1)
            .labelStyle(.iconOnly)
            .contentShape(Rectangle())
            .padding(8)
            .scaleEffect(configuration.isPressed ? 0.85 : 1)
            .animation(.bouncy(duration: 0.2, extraBounce: 0.2), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { newValue in
                onPress(newValue)
            }
    }
}

struct VideoPlayerDrawerContentButton: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            BlurView()
                .cornerRadius(7)

            configuration.label
                .font(.subheadline.weight(.semibold))
        }
    }
}

extension ButtonStyle where Self == VideoPlayerDrawerContentButton {

    static var videoPlayerDrawerContent: VideoPlayerDrawerContentButton {
        VideoPlayerDrawerContentButton()
    }
}
