//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import Defaults
import SwiftUI

struct GestureSettingsView: View {
    
    @Default(.VideoPlayer.Gesture.horizontalPanGesture)
    private var horizontalPanGesture
    @Default(.VideoPlayer.Gesture.horizontalSwipeGesture)
    private var horizontalSwipeGesture
    @Default(.VideoPlayer.Gesture.longPressGesture)
    private var longPressGesture
    @Default(.VideoPlayer.Gesture.pinchGesture)
    private var pinchGesture
    @Default(.VideoPlayer.Gesture.verticalPanGestureLeft)
    private var verticalPanGestureLeft
    @Default(.VideoPlayer.Gesture.verticalPanGestureRight)
    private var verticalPanGestureRight
    
    var body: some View {
        Form {
            
            EnumPicker(title: "Horizontal Pan", selection: $horizontalPanGesture)
            
            EnumPicker(title: "Horizontal Swipe", selection: $horizontalSwipeGesture)
            
            EnumPicker(title: "Long Press", selection: $longPressGesture)
            
            EnumPicker(title: "Pinch", selection: $pinchGesture)
            
            EnumPicker(title: "Left Vertical Pan", selection: $verticalPanGestureLeft)
            
            EnumPicker(title: "Right Vertical Pan", selection: $verticalPanGestureRight)
        }
    }
}
