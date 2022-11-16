//
//  SplashView.swift
//

import SwiftUI

struct SplashView: View {
    
    @StateObject var splashViewModel = SplashViewModel()
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(splashViewModel.imageName)
                        .onboardingStyle()
                    Spacer()
                }
                Spacer()
                
                RouterLink(binding: $splashViewModel.showMainView,
                           destination: NavigationLocation.main(selectedTab: .dashboard).wrappedView(),
                           embedInNavigationController: false)
            }
        }
        .background(Color.onboardingBackground.edgesIgnoringSafeArea(.all))
        .onAppear {
            splashViewModel.showMainView = true
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    
    static var previews: some View {
        SplashView()
    }
}
