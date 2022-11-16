//
//  HostingController.swift
//

import SwiftUI

class HostingController<Content>: UIHostingController<Content> where Content: View {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
