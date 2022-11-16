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

            Text(viewModel.title)
                .styled(.primary)

            Text(viewModel.subtitle)
                .styled(.customFull(.openSans, .regular, 16, .center, secondaryTextColor))
                .padding(.bottom, 10)
                .fixedSize(horizontal: false, vertical: true)

            VStack {
                TextView(
                    text: $viewModel.formText.onUpdate {
                        viewModel.validateForm(with: viewModel.formText)
                    },
                    isEditing: $isEditing,
                    placeholder: "Description of problem goes here…",
                    font: .custom(.openSans, weight: .regular, size: 16),
                    textColor: Color.secondaryText.uiColor(),
                    keyboardDismissMode: .interactive,
                    shouldChange: { _, string in
                        return viewModel.isTextInLimit(newText: string)
                    }
                )
                .frame(height: 130, alignment: .center)

                StateButton(
                    state: $viewModel.sendButtonState,
                    defaultState: .normal(viewModel.buttonText),
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

            Text("SUCCESS!")
                .styled(.primary)
                .foregroundColor(primaryTextColor)

            Text((theme == .dark) ? "Your message has been sent! We will get back to you ASAP!" : "We will contact you via email within 48 hours.")
                .styled(.customFull(.openSans, .regular, 15, .center, secondaryTextColor))
                .padding(.bottom, 10)
                .padding(.horizontal)

            ActionButton(
                text: "Continue".uppercased(),
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
