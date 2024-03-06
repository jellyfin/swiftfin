//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2024 Jellyfin & Jellyfin Contributors
//

import SwiftUI

// https://movingparts.io/variadic-views-in-swiftui

// TODO: add customization for spacing, or just have 0 and have separator handle spacing
struct SeparatorHStack<Content: View>: View {

    private var content: () -> Content
    private var separator: () -> any View

    var body: some View {
        _VariadicView.Tree(SeparatorHStackLayout(separator: separator)) {
            content()
        }
    }
}

extension SeparatorHStack {

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.init(
            content: content,
            separator: { RowDivider() }
        )
    }

    func separator(@ViewBuilder _ content: @escaping () -> any View) -> Self {
        copy(modifying: \.separator, with: content)
    }
}

extension SeparatorHStack {

    struct SeparatorHStackLayout: _VariadicView_UnaryViewRoot {

        var separator: () -> any View

        @ViewBuilder
        func body(children: _VariadicView.Children) -> some View {

            let last = children.last?.id

            localHStack {
                ForEach(children) { child in
                    child

                    if child.id != last {
                        separator()
                            .eraseToAnyView()
                    }
                }
            }
        }

        @ViewBuilder
        private func localHStack(@ViewBuilder content: @escaping () -> some View) -> some View {
            #if os(tvOS)
            HStack(spacing: 0) {
                content()
            }
            #else
            HStack {
                content()
            }
            #endif
        }
    }
}
