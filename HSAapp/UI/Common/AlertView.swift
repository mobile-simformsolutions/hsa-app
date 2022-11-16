//
//  AlertView.swift
//

import SwiftUI

struct AlertView: View {
    typealias ButtonHandler = () -> Void
    
    let image: Image
    let title: String
    let subtitle: String?
    let buttonTitle: String?
    let onButtonTap: ButtonHandler?
    var screenName: AnalyticsScreen?
    
    var body: some View {
        VStack {
            Spacer()
            
            image
                .onboardingStyle()
                .padding(.bottom)
            
            VStack(spacing: 0) {
                Text(title)
                    .font(Font.custom(.poppins, weight: .medium, size: 24, relativeTo: .body))
                    .foregroundColor(Color.primaryText)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .styled(.secondary)
                }
            }.padding(.bottom)
            
            if let buttonTitle = buttonTitle, let onButtonTap = onButtonTap {
                Button(buttonTitle.uppercased(), action: onButtonTap)
                    .buttonStyle(PrimaryButtonStyle())
            }
        }.padding(.horizontal, 30)
        .introspectNavigationController(customize: { navigationController in
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.backgroundColor = Color.onboardingBackground.uiColor()
            navBarAppearance.titleTextAttributes = [
                NSAttributedString.Key.font: UIFont(name: "\(FontFace.poppins.rawValue)-\(FontWeight.medium.rawValue)", size: 18) as Any, NSAttributedString.Key.foregroundColor: UIColor.white]

            navigationController.navigationBar.standardAppearance = navBarAppearance
            navigationController.navigationBar.compactAppearance = navBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
            navigationController.navigationBar.prefersLargeTitles = false
        })
        .embedInScrollViewIfNeeded(stretchContentFullHeight: true)
        .configureNavigationTitleImage()
        .analyticsScreen(name: screenName?.rawValue ?? "")
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView(
            image: Image("18"),
            title: "Our apologies!",
            subtitle: "By law, HSA cardholders must be 18 years of age or older",
            buttonTitle: "Continue",
            onButtonTap: { })
    }
}
