//
//  HSAAppNavigationBar.swift
//

import SwiftUI

struct HSANavigation: ViewModifier {
    var title: String
    var menuImage: String
    @Binding var showMenu: Bool

    func body(content: Content) -> some View {
        return content
            .configureNavigationTitleImage()
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(
                leading:
                    Button(action: {
                        withAnimation {
                            showMenu.toggle()
                        }

                    }, label: {
                        Image(menuImage).renderingMode(.template).foregroundColor(Color.navigationNotSelected)

                    })
            )
            .configureNavBar()
    }
}

struct HSANavBar: ViewModifier {
    var isTransparent: Bool
    var showAppLogo: Bool
    var isEnabled: Bool?
    
    func body(content: Content) -> some View {
        content.introspectNavigationController { navigationController in
            let navBarAppearance = UINavigationBarAppearance()
            
            if isTransparent {
                navBarAppearance.configureWithTransparentBackground()
            } else {
                navBarAppearance.configureWithDefaultBackground()
                navBarAppearance.backgroundColor = Color.navigationBackground.uiColor()
            }

            navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

            navigationController.navigationBar.standardAppearance = navBarAppearance
            navigationController.navigationBar.compactAppearance = navBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance

            if let isEnabled = isEnabled {
                navigationController.navigationBar.isUserInteractionEnabled = isEnabled
            }
            navigationController.navigationBar.prefersLargeTitles = false
            navigationController.navigationBar.tintColor = Color.navigationNotSelected.uiColor()
        }
    }
}


extension View {
    func configureNavigation(title: String, menuImage: String = "menu", showMenu: Binding<Bool>) -> some View {
        modifier(HSANavigation(title: title, menuImage: menuImage, showMenu: showMenu))
    }

    /// This configures the navbar as transparent
    func configureNavBar(transparent: Bool = false, isEnabled: Bool? = true) -> some View {
        modifier(HSANavBar(isTransparent: transparent, showAppLogo: false, isEnabled: isEnabled))
    }

    func configureNavigationTitleImage() -> some View {
        self
            .navigationBarTitle(appString.hsaText(), displayMode: .inline)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image("navigationAppLogo")
                            .resizable()
                            .frame(width: CGFloat(32), height: CGFloat(32), alignment: .center)
                    }
                    .padding(2)
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
    }
}
