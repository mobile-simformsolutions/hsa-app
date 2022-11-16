//
//  MainViewModel.swift
//

import SwiftUI
import Resolver

class MainViewModel: ObservableObject {
    
    // MARK: - Variables
    //
    @Injected private var userManager: UserManager
    @Binding var showMenu: Bool

    init(showMenu: Binding<Bool>) {
        self._showMenu = showMenu
    }
}
