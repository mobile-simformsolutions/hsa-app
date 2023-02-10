//
//  MenuViewModel.swift
//

import SwiftUI

enum MenuRowType: String, CaseIterable, RawRepresentable, Identifiable {
    var id: RawValue { rawValue }
    
    case faq
    case contactus
    
    func title() -> String {
        switch self {
        case .faq:
            return appString.faqText()
        case .contactus:
            return appString.contactUs()
        }
    }
    
    func image() -> Image {
        switch self {
        case .faq:
            return Image("FAQ")
        case .contactus:
            return Image("contactUs")
        }
    }
}

class MenuViewModel: ObservableObject {
    
    @Binding var showMenu: Bool
    @Published var currentLink: URLLink?
    
    init(showMenu: Binding<Bool>) {
        self._showMenu = showMenu
    }
    
    func rows() -> [MenuRowType] {
        return MenuRowType.allCases
    }
    
    func selected(_ row: MenuRowType) {
        switch row {
        case .faq:
            guard let url = Constants.faqURL else { return }
            currentLink = URLLink(title: appString.faqText(), url: url)
        default:
            withAnimation {
                self.showMenu = false
            }
        }
    }
    
    func menuToggle() {
        withAnimation {
            self.showMenu.toggle()
        }
    }
}
