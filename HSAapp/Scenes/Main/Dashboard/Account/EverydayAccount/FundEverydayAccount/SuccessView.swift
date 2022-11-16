//
//  SuccessView.swift
//  Zenda
//
//  Created by Chaitali Lad on 15/02/22.
//

import SwiftUI

struct SuccessView: View {
    
    var successTitle: String?
    var title: String
    var sourceScreen: AnalyticsScreen?
    var buttonName = "Continue"
    var buttonAction: (() -> Void)
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("Success")
                .resizable()
                .onboardingPrimaryStyle()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 35)
            
            Text(successTitle ?? "Success!")
                .styled(.customFull(.poppins, .medium, 24, .center, .primaryText))
            
            Text(title)
                .styled(.customFull(.openSans, .regular, 15, .leading, .secondaryText))
                .padding(.bottom, 24)
                .padding(.horizontal, 15)

            ActionButton(
                text: buttonName.uppercased(),
                action: {
                    onMain {
                        buttonAction()
                    }
                }
            )
        }
        .padding(.horizontal, 29)
        .padding(.bottom, 32)
        .background(Color.whiteBackground.edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
        .configureNavigationTitleZendaImage()
        .analyticsScreen(name: sourceScreen?.rawValue ?? "")
    }
}

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        return SuccessView(title: "12", buttonAction: { })
    }
}
