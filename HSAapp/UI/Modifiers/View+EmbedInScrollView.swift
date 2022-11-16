//
//  View+EmbedInScrollView.swift
//

import SwiftUI

extension View {
    func embedInScrollViewIfNeeded(stretchContentFullHeight: Bool = false) -> some View {

        Group {
            // Add scroll view when screen height is lesser than 667
            if UIScreen.main.bounds.height < 667 {
                ScrollViewIfNeeded(stretchContentFullHeight: stretchContentFullHeight) {
                    self
                }
            } else {
                self
            }
        }
    }
}

private extension View {
    @ViewBuilder func embedInScrollView(when shouldEmbed: Bool) -> some View {
        if shouldEmbed {
            ScrollView {
                self
            }
        } else {
            self
        }
    }
}

private struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

private struct EmbedInScroll: ViewModifier {
    @State private var fitsInSuperview = false

    func body(content: Content) -> some View {
        GeometryReader { superviewGeometry in
            content
                .background(
                    GeometryReader { backgroundGeometry in
                        // Store background height in view preference
                        Color.clear.preference(
                            key: ContentHeightKey.self,
                            value: backgroundGeometry.frame(in: .local).size.height
                        )
                    }
                )
                .embedInScrollView(when: !fitsInSuperview)
                .onPreferenceChange(ContentHeightKey.self) { contentHeight in
                    fitsInSuperview = contentHeight <= superviewGeometry.size.height
                }
        }
    }
}
