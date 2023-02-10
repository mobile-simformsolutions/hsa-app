//
//  ContactUsView.swift
//

import SwiftUI
import UIKit
import TextView

struct ContactUsView: View {
    
    enum SuccessAction {
        case pop
        case custom(() -> Void)
    }
    
    @StateObject var viewModel: ContactUsViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var isEditing = false
    @State private var shouldShowSuccess = false
    
    var theme: Theme
    var successAction: SuccessAction = .pop

    private var background: Color {
        switch theme {
        case .light:
            return Color.whiteBackground
        case .dark:
            return Color.onboardingBackground
        }
    }

    private var primaryTextColor: Color {
        switch theme {
        case .light:
            return .primaryText
        case .dark:
            return .onboardingPrimaryText
        }
    }

    private var secondaryTextColor: Color {
        switch theme {
        case .light:
            return .secondaryText
        case .dark:
            return .onboardingSecondaryText
        }
    }

    var body: some View {
        ZStack {
            if !shouldShowSuccess {
                ZStack {
                    background.edgesIgnoringSafeArea(.all)

                    VStack {
                        Spacer()
                        contactUs
                    }
                    .embedInScrollViewIfNeeded(stretchContentFullHeight: true)
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    )
                ).zIndex(1)
            } else {
                ZStack {
                    background.edgesIgnoringSafeArea(.all)

                    VStack {
                        Spacer()
                        success
                    }.embedInScrollViewIfNeeded(stretchContentFullHeight: true)
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    )
                ).zIndex(2)
            }
        }
        .padding(.bottom)
        .configureNavigationTitleImage()
        .hsaAlert(item: $viewModel.retryAlert)
        .isDisabled(viewModel.showSpinner)
        .background(background.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Style
//
extension ContactUsView {
    enum Theme {
        case light
        case dark
    }
}

// MARK: - Views
//
private extension ContactUsView {
    var contactUs: some View {
        VStack {
            Image(viewModel.imageName)
                .onboardingStyle(width: 225, height: 225)
                .padding()

            Text(appString.contactusText())
                .styled(.primary)

            Text(appString.greatExperince())
                .styled(.customFull(.poppins, .regular, 16, .center, secondaryTextColor))
                .padding(.bottom, 10)
                .fixedSize(horizontal: false, vertical: true)

            VStack {
                TextView(
                    text: $viewModel.formText.onUpdate {
                        viewModel.validateForm(with: viewModel.formText)
                    },
                    isEditing: $isEditing,
                    placeholder: appString.descriptionOfProblem(),
                    font: .custom(.poppins, weight: .regular, size: 16),
                    textColor: Color.secondaryText.uiColor(),
                    keyboardDismissMode: .interactive,
                    shouldChange: { _, string in
                        return viewModel.isTextInLimit(newText: string)
                    }
                )
                .frame(height: 130, alignment: .center)

                StateButton(
                    state: $viewModel.sendButtonState,
                    defaultState: .normal(appString.sendMessage()),
                    shouldShowErrorState: .constant(false)
                ) {
                    isEditing = false
                    viewModel.sendSupportRequest { result in
                        switch result {
                        case .success:
                            withAnimation {
                                shouldShowSuccess = true
                            }
                        case let .failure(error):
                            Log(.error, message: error.localizedDescription)
                        }
                    }
                }
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.onboardingBorder, lineWidth: 3)
            )
            .introspectTextView { textView in
                textView.keyboardType = .asciiCapable
            }
        }
        .padding(.horizontal)
        .background(background.edgesIgnoringSafeArea(.all))
    }

    var success: some View {
        VStack {
            Image("MessageSent")
                .resizable()
                .onboardingStyle(width: 225, height: 225)
                .aspectRatio(contentMode: .fit)
                .padding()

            Text(appString.successText())
                .styled(.primary)
                .foregroundColor(primaryTextColor)

            Text((theme == .dark) ? appString.yourMessage() : appString.weWillContact())
                .styled(.customFull(.poppins, .regular, 15, .center, secondaryTextColor))
                .padding(.bottom, 10)
                .padding(.horizontal)

            ActionButton(
                text: appString.continue(),
                action: {
                    switch successAction {
                    case .pop:
                        presentationMode.wrappedValue.dismiss()
                    case let .custom(action):
                        action()
                    }
                }
            )
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        .background(background.edgesIgnoringSafeArea(.all))
    }
}

struct ContactUsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactUsView(viewModel: ContactUsViewModel(supportRequestType: .generic, sourceScreenName: .hamburgerMenuContactusLink), theme: .dark)
    }
}
