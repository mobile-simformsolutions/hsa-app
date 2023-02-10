//
//  View+Border.swift
//

import SwiftUI

// swiftlint:disable identifier_name
struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading:
                    return rect.minX
                case .trailing:
                    return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing:
                    return rect.minY
                case .bottom:
                    return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom:
                    return rect.width
                case .leading, .trailing:
                    return width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom:
                    return width
                case .leading, .trailing:
                    return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
            path.addLine(to: CGPoint(x: w / 2.0, y: 0))
        }
        return path
    }
}
// swiftlint:enable identifier_name

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
