//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2025 Jellyfin & Jellyfin Contributors
//

import Stinsen
import SwiftUI

final class UserProfileImageCoordinator: NavigationCoordinatable {

    // MARK: - Navigation Components

    let stack = Stinsen.NavigationStack(initial: \UserProfileImageCoordinator.start)

    @Root
    var start = makeStart

    // MARK: - Routes

    @Route(.push)
    var cropImage = makeCropImage

    // MARK: - Observed Object

    @ObservedObject
    var viewModel: UserProfileImageViewModel

    // MARK: - Initializer

    init(viewModel: UserProfileImageViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Views

    func makeCropImage(image: UIImage) -> some View {
        #if os(iOS)
        UserProfileImageCropView(viewModel: viewModel, image: image)
        #else
        AssertionFailureView("not implemented")
        #endif
    }

    @ViewBuilder
    func makeStart() -> some View {
        #if os(iOS)
        UserProfileImagePickerView()
        #else
        AssertionFailureView("not implemented")
        #endif
    }
}
