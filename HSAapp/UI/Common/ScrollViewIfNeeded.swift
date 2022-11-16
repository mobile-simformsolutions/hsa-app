//
//  ScrollViewIfNeeded.swift
//

import Foundation
import SwiftUI


struct ScrollViewIfNeeded<Content>: View where Content: View {
    /// The scroll view's content.
    ///
    var content: Content

    /// A value that indicates whether the scroll view displays the scrollable
    /// component of the content offset, in a way that's suitable for the
    /// platform.
    ///
    /// The default is `true`.
    ///
    var showsIndicators: Bool

    /// Defines whether the content should be stretched to full height or not
    /// This will align the content to bottom of the screen if `content` includes a `Spacer()` at the top
    ///
    /// The default is `false`.
    ///
    private let stretchContentFullHeight: Bool

    /// Creates a new instance that's scrollable in the direction of the given
    /// axis and can show indicators while scrolling if the
    /// Content's size is greater than the ScrollView's.
    ///
    /// - Parameters:
    ///   - axes: The scroll view's scrollable axis. The default axis is the
    ///     vertical axis.
    ///   - fullHeight: If enabled this adds a frame to stretch the content to full height
    ///   - showsIndicators: A Boolean value that indicates whether the scroll
    ///     view displays the scrollable component of the content offset, in a way
    ///     suitable for the platform. The default value for this parameter is
    ///     `true`.
    ///   - content: The view builder that creates the scrollable view.
    ///
    init(
        stretchContentFullHeight: Bool = true,
        showsIndicators: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.showsIndicators = showsIndicators
        self.stretchContentFullHeight = stretchContentFullHeight
        self.content = content()
    }

    @State private var fitsVertically = false

    /// Minimum height to fill the whole scrollview
    ///
    @State private var minHeightToFill: CGFloat = 0

    /// Size of the content inside the scrollview
    ///
    @State private var contentHeight: CGFloat = 0

    /// Screen height
    ///
    @State private var geometryHeight: CGFloat = 0

    var activeScrollingDirections: Axis.Set {
        fitsVertically ? [] : Axis.Set.vertical
    }

    var body: some View {
        GeometryReader { geometryReader in
            ScrollView(activeScrollingDirections, showsIndicators: showsIndicators) {
                VStack {
                    content
                        .if(stretchContentFullHeight) {
                            $0.padding(.top, minHeightToFill)
                        }
                        .background(
                            GeometryReader {
                                // calculate size by consumed background and store in
                                // view preference
                                Color.clear.preference(
                                    key: ViewSizeKey.self,
                                    value: $0.frame(in: .local).size
                                )
                            }
                        )
                }
            }
            .onPreferenceChange(ViewSizeKey.self) { contentSize in
                geometryHeight = geometryReader.size.height
                contentHeight = contentSize.height
                fitsVertically = contentSize.height <= geometryReader.size.height
            }
        }
        .if(stretchContentFullHeight) {
            $0.readSize { viewSize in
                if contentHeight > 0 {
                    minHeightToFill = max(viewSize.height - contentHeight, 0)
                }

                fitsVertically = contentHeight <= viewSize.height
            }
        }
    }

    private struct ViewSizeKey: PreferenceKey {
        static var defaultValue: CGSize { .zero }
        static func reduce(value: inout Value, nextValue: () -> Value) {
            let next = nextValue()
            value = CGSize(
                width: value.width + next.width,
                height: value.height + next.height
            )
        }
    }
}
