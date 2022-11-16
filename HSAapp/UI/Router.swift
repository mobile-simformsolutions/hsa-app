//
//  Router.swift
//

import SwiftUI

struct RouterLink: View {
    @Binding var binding: Bool
    var destination: AnyView
    var embedInNavigationController = false
    var allowBackNavigation = true
    var shouldShowNavigationBar = true

    var body: some View {
        if binding == true {
            var newView: AnyView
            if embedInNavigationController {
                newView = AnyView(
                    NavigationView {
                        destination
                            .navigationBarBackButtonHidden(!allowBackNavigation)
                            .navigationBarHidden(!shouldShowNavigationBar)
                            .configureNavBar()
                    }.navigationViewStyle(StackNavigationViewStyle())
                )
            } else {
                newView = destination
            }
            UIApplication.shared.resetScene(to: newView)
        }
        return Spacer().frame(width: 0, height: 0, alignment: .center)
    }
}
