//
//  NavigationLazyView.swift
//

import SwiftUI

/*

 Sources:
  - https://medium.com/better-programming/swiftui-navigation-links-and-the-common-pitfalls-faced-505cbfd8029b
  - https://gist.github.com/chriseidhof/d2fcafb53843df343fe07f3c0dac41d5
  - https://twitter.com/chriseidhof/status/1144242544680849410?lang=en

 Example usage:
    struct ContentView: View {
        var body: some View {
            NavigationView {
                NavigationLink(destination: NavigationLazyView(Text("My details page")) {
                    Text("Go to details")
                }
            }
        }
    }
*/

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
