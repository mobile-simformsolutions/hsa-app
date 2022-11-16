//
//  View+Alert.swift
//

import SwiftUI

extension View {
    /// Displays `.alert` or `.sheet` based on the error inside `AlertConfiguration`
    /// Important to note here is that the view cannot use another `.alert`,
    /// as 2 alerts on one SwiftUI View are forbidden
    ///
    func hsaAlert(item: Binding<AlertConfiguration?>)
    -> some View {
        let serverErrorMsg = "We are experiencing technical problems. Please close the app and try again later."
        let noNetworkErrorMsg = "Something went wrong. Make sure you have connectivity and try again…."
        let genericErrorMsg = "Something went wrong. Please try again…."

        let alertConfig = item.wrappedValue

        var showErrorSheet = false
        var showErrorAlert = false

        var subtitle = noNetworkErrorMsg
        var shouldShowButton = true

        if let alertConfig = item.wrappedValue {
            if let error = alertConfig.error as? APIError {
                switch error {
                case .noNetwork:
                    showErrorSheet = true
                case .serverError:
                    showErrorSheet = true
                    shouldShowButton = false
                    subtitle = serverErrorMsg
                case .requestTimeout:
                    showErrorSheet = true
                    subtitle = genericErrorMsg
                default:
                    showErrorAlert = true
                }
            } else {
                showErrorAlert = true
            }
        } else {
            showErrorSheet = false
            showErrorAlert = false
        }

        let alertBinding = Binding(
            get: {
                showErrorAlert ? alertConfig : nil
            }, set: {
                item.wrappedValue = $0
            }
        )

        let buttonTitle = alertConfig?.retryAction != nil ? "Try again" : "Close"

        return self
            .background(EmptyView()
                .sheet(
                    isPresented: .constant(showErrorSheet),
                    onDismiss: { item.wrappedValue = nil },
                    content: {
                        NavigationView {
                            AlertView(
                                image: Image("oops"),
                                title: "OOPS!",
                                subtitle: subtitle,
                                buttonTitle: shouldShowButton ? buttonTitle : nil,
                                onButtonTap: {
                                    item.wrappedValue = nil

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        withAnimation {
                                            alertConfig?.retryAction?()
                                        }
                                    }
                                }
                            )
                            .navigationBarItems(trailing: Button(action: {
                                DispatchQueue.main.async {
                                    item.wrappedValue = nil
                                    alertConfig?.closeButtonAction?()
                                }
                            }, label: {
                                Image("close")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }))
                            .navigationBarBackButtonHidden(true)
                        }
                    }
                )
                .alert(item: alertBinding) { config in
                    Alert.configure(config)
                }
            )
    }
}

struct WrappedInNavigationView<T: View>: View {
    let rootView: T

    var body: some View {
        return NavigationView {
            rootView
        }
    }
}
