//
//  SplashViewModel.swift
//

import Foundation
import SwiftUI

class SplashViewModel: ObservableObject {
    
    // MARK: - Variables
    //
    @Published var showMainView = false
    @Published var imageName: String = "emptyHSAActivity"

}
