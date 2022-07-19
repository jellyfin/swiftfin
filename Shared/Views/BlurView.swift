//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI
import UIKit

struct BlurView: UIViewRepresentable {

	#if os(tvOS)
		var style: UIBlurEffect.Style = .regular
	#else
		var style: UIBlurEffect.Style = .systemUltraThinMaterial
	#endif

	func makeUIView(context: Context) -> UIVisualEffectView {
		let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}

	func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
		uiView.effect = UIBlurEffect(style: style)
	}
}
