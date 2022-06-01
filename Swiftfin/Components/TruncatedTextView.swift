//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2022 Jellyfin & Jellyfin Contributors
//

import SwiftUI

// Modification of: https://prafullkumar77.medium.com/swiftui-how-to-make-see-more-see-less-style-button-at-the-end-of-text-675f859c2c4f

struct TruncatedTextView: View {

	@State
	private var truncated: Bool = false
	@State
	private var shrinkText: String
	private var text: String
	let font: UIFont
	let lineLimit: Int
	let seeMoreAction: () -> Void

	private var moreLessText: String {
		if !truncated {
			return ""
		} else {
			return L10n.seeMore
		}
	}

	init(_ text: String,
	     lineLimit: Int,
	     font: UIFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
	     seeMoreAction: @escaping () -> Void)
	{
		self.text = text
		self.lineLimit = lineLimit
		_shrinkText = State(wrappedValue: text)
		self.font = font
		self.seeMoreAction = seeMoreAction
	}

	var body: some View {
		VStack(alignment: .center) {
			Text(shrinkText)
				.lineLimit(lineLimit)
				.font(Font(font))
				.background {
					// Render the limited text and measure its size
					Text(text)
						.lineLimit(lineLimit + 2)
						.font(Font(font))
						.background {
							GeometryReader { visibleTextGeometry in
								Color.clear
									.onAppear {
										let size = CGSize(width: visibleTextGeometry.size.width, height: .greatestFiniteMagnitude)
										let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
										var low = 0
										var heigh = shrinkText.count
										var mid = heigh
										while (heigh - low) > 1 {
											let attributedText = NSAttributedString(string: shrinkText, attributes: attributes)
											let boundingRect = attributedText.boundingRect(with: size,
											                                               options: NSStringDrawingOptions
											                                               	.usesLineFragmentOrigin,
											                                               context: nil)
											if boundingRect.size.height > visibleTextGeometry.size.height {
												truncated = true
												heigh = mid
												mid = (heigh + low) / 2

											} else {
												if mid == text.count {
													break
												} else {
													low = mid
													mid = (low + heigh) / 2
												}
											}
											shrinkText = String(text.prefix(mid))
										}

										if truncated {
											shrinkText = String(shrinkText.prefix(shrinkText.count - 2))
										}
									}
							}
						}
						.hidden()
				}
				.if(truncated, transform: { view in
					view.mask {
						LinearGradient(gradient: Gradient(stops: [
							.init(color: .white, location: 0),
							.init(color: .white, location: 0.2),
							.init(color: .white.opacity(0), location: 1),
						]), startPoint: .top, endPoint: .bottom)
					}
				})

			if truncated {
				Button {
					seeMoreAction()
				} label: {
					Text(moreLessText)
						.foregroundColor(.jellyfinPurple)
				}
			}
		}
	}
}
