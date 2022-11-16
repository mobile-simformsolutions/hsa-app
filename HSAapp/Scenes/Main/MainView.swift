//
//  MainView.swift
//

import SwiftUI
import Introspect
import Combine

enum MainViewTab: Int {
    case dashboard = 1, hsaAccount
}

struct MainView: View {
    
    @State private var showMenu: Bool = false
    @State private var showContactUs: Bool = false
    @State private var selectedTabView: MainViewTab
    private let menuPercent: CGFloat = 1
    
    init(_ selectedTabView: MainViewTab) {
        UITabBar.appearance().barTintColor = Color.navigationBackground.uiColor()
        UITabBar.appearance().unselectedItemTintColor = Color.navigationNotSelected.uiColor()
        UITabBar.appearance().tintColor = Color.navigationSelected.uiColor()
        self._selectedTabView = State(initialValue: selectedTabView)
    }
    
    private func menuWidth(_ totalWidth: CGFloat) -> CGFloat {
        return totalWidth * menuPercent
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    MainNavigation(showMenu: $showMenu, selectedTabView: $selectedTabView, showContactUs: $showContactUs)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: $showMenu.wrappedValue ? menuWidth(geometry.size.width) : 0)
                    
                    if $showMenu.wrappedValue {
                        MenuView(
                            showMenu: $showMenu,
                            onRowTap: { handleMenuRowTap(rowType: $0) }
                        )
                        .frame(width: menuWidth(geometry.size.width))
                        .transition(.move(edge: .leading))
                    }
                }
                .analyticsScreen(name: .dashboard)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .configureNavBar()
            .configureNavigation(title: "", menuImage: showMenu ? "closeLight" : "menu", showMenu: $showMenu)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func handleMenuRowTap(rowType: MenuRowType) {
        switch rowType {
        case .contactus:
            showContactUs = true
        default:
            break
        }
    }
}
struct MainNavigation: View {
    
    @ObservedObject var viewModel: MainViewModel
    @Binding private var selectedTabView: MainViewTab
    @Binding var showContactUs: Bool
    
    init(showMenu: Binding<Bool>, selectedTabView: Binding<MainViewTab>, showContactUs: Binding<Bool>) {
        viewModel = MainViewModel(showMenu: showMenu)
        self._selectedTabView = selectedTabView
        self._showContactUs = showContactUs
    }
    
    var body: some View {
        tabView
            .accentColor(Color.navigationSelected)
            .introspectTabBarController { controller in
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = Color.navigationBackground.uiColor()
                appearance.stackedLayoutAppearance.selected.badgeBackgroundColor = Color.errorText.uiColor()
                appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = Color.errorText.uiColor()
                
                controller.tabBar.backgroundColor = Color.navigationBackground.uiColor()
                controller.tabBar.unselectedItemTintColor = Color.navigationNotSelected.uiColor()
                controller.tabBar.tintColor = Color.navigationSelected.uiColor()
                controller.tabBar.standardAppearance = appearance
            }
        
        NavigationLink(
            destination: ContactUsView(viewModel: .init(supportRequestType: .generic, sourceScreenName: .hamburgerMenuContactusLink), theme: .light),
            isActive: $showContactUs,
            label: {
                EmptyView()
            })
    }
    
    private func tabIcon(imageName: String, active: Bool) -> some View {
        Image(imageName).resizable().frame(width: 22, height: 22, alignment: .center)
    }
    
    private func systemTabIcon(imageName: String, active: Bool) -> some View {
        Image(systemName: imageName)
            .resizable().frame(width: 33, height: 33, alignment: .center)
    }
    
    private var tabView: some View {
        TabView(selection: $selectedTabView) {
            DashboardView(selectedTab: $selectedTabView)
                .disabled($viewModel.showMenu.wrappedValue ? true : false)
                .tabItem {
                    tabIcon(imageName: "dashboard", active: selectedTabView == MainViewTab.dashboard)
                    Text("Dashboard")
                }
                .tag(MainViewTab.dashboard)
            
            HsaAccountView(selectedTab: $selectedTabView)
                .disabled($viewModel.showMenu.wrappedValue ? true : false)
                .tabItem {
                    tabIcon(imageName: "hsaAccount", active: selectedTabView == MainViewTab.hsaAccount)
                    Text("HSA")
                }
                .tag(MainViewTab.hsaAccount)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(.dashboard)
    }
}
