//
//  MenuView.swift
//

import SwiftUI

struct MenuView: View {
    
    typealias TapHandler = (MenuRowType) -> Void
    @ObservedObject var viewModel: MenuViewModel
    @StateObject var webViewStore = WebViewStore()
    var onRowTap: TapHandler?
    
    init(showMenu: Binding<Bool>, onRowTap: TapHandler?) {
        viewModel = MenuViewModel(showMenu: showMenu)
        self.onRowTap = onRowTap
    }
    
    var body: some View {
        HStack {
            VStack {
                Spacer.small()
                ScrollView {
                    ForEach(viewModel.rows(), id: \.id) { menuRowType in
                        MenuRowView(type: menuRowType)
                            .onTapGesture {
                                viewModel.selected(menuRowType)
                                onRowTap?(menuRowType)
                            }
                    }
                    Spacer()
                }
            }
            .padding(.all, 0)
            Divider()
                .style(.menu).edgesIgnoringSafeArea(.all)
        }
        .background(Color.secondaryText.edgesIgnoringSafeArea(.all))
        .sheet(item: $viewModel.currentLink) { link in
            NavigationView {
                ZStack {
                    WebView(webView: webViewStore.webView)
                        .navigationBarTitle(Text(verbatim: link.title), displayMode: .inline)
                        .navigationBarItems(
                            trailing:
                                Button(appString.close()) {
                                    viewModel.currentLink = nil
                                }
                        )
                    
                    ActivityIndicator(isAnimating: .constant(true), style: .medium)
                        .opacity(webViewStore.webView.isLoading ? 1 : 0)
                }
            }.onAppear {
                self.webViewStore.webView.load(URLRequest(url: link.url))
            }
        }
        
    }
}

struct MenuRowView: View {
    
    @State var type: MenuRowType
    
    var body: some View {
        VStack {
            Spacer.medium()
            HStack {
                Spacer.small()
                type.image()
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.navigationNotSelected)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30, alignment: .center)
                Spacer.small()
                Text(type.title()).styled(.customFull(.poppins, .regular, 16, .leading, Color.darkBackground))
                Spacer()
                Image(systemName: "chevron.forward").resizable()
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.navigationNotSelected)
                    .frame(width: 18, height: 18, alignment: .center)
            }
            Spacer.medium()
            Divider()
                .style(.menu).frame(height: 1)
        }
        .disabled(false).padding(.leading).padding(.trailing)
    }
    
    private func getUserNameInitals(name: String) -> String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: name) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
    
}

struct MenuView_Previews: PreviewProvider {
    
    static var previews: some View {
        MenuView(showMenu: Binding.constant(false), onRowTap: nil)
    }
}
