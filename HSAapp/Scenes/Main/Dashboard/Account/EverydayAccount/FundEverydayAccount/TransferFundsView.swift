//
//  TransferFundsView.swift
//  Zenda
//
//  Created by Chaitali Lad on 15/02/22.
//

import SwiftUI

struct TransferFundsView: View {
    
    @StateObject var viewModel: TransferFundsViewModel
    
    @State var goToEverydayTabView = false

    var body: some View {
        RouterLink(binding: $goToEverydayTabView, destination: NavigationLocation.main(selectedTab: .everydayAccount).wrappedView(), embedInNavigationController: false)
        
        VStack {
            NavigationLink(
                destination: SuccessView(
                    title: "Your transfer is being processed\n$\(viewModel.formattedTransferedAmount()) will be deposited into your account within 3-5 business days",
                    buttonAction: {
                        withAnimation {
                            if viewModel.goToSpecificView {
                                viewModel.showSuccessView = false
                                goToEverydayTabView = true
                            } else {
                                NavigationUtil().popToRootView()
                            }
                        }
                    }),
                isActive: $viewModel.showSuccessView,
                label: {
                    EmptyView()
                }
            )
            .isDetailLink(false)
            
            Text("Transfer Funds")
                .styled(.customFull(.poppins, .medium, 24, .center, .primaryText))
            
            ZStack {
                
                VStack(spacing: 0) {
                    HStack {
                        Image("fromAccount")
                            .resizable()
                            .frame(width: 12, height: 12, alignment: .center)
                        
                        AnyView(titleView(contentView: AnyView(fromAccount)))
                            .padding(.trailing, 38)
                    }
                    
                    HStack {
                        Image("toAccount")
                            .resizable()
                            .frame(width: 12, height: 14, alignment: .center)
                        
                        AnyView(titleView(contentView: AnyView(toAccount)))
                            .padding(.trailing, 38)
                    }
                    .padding(.top, 7)
                }
                
                HStack {
                    Image("transferArrow")
                        .resizable()
                        .frame(width: 14, height: 16, alignment: .center)
                        .padding(.leading, -1)
                    
                    Spacer()
                    
                    Image("toggleAccounts")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .onTapGesture {
                            viewModel.shouldTransferFromDDAToExternal.toggle()
                            viewModel.updateAccountLabels()
                        }
                }
            }
            
            Divider().style(.list)
                .padding(.vertical, 16)
            
            AnyView(titleView(contentView: AnyView(totalAmount)))
            
            StateButton(state: $viewModel.transferFundButtonState,
                        defaultState: .normal(viewModel.transferFundButtonLabel),
                        shouldShowErrorState: $viewModel.shouldDisplayValidationResult) {
                hideKeyboard()
                viewModel.transferFunds()
            }
            .padding(.vertical, 16)
                    
            Spacer()
        }
        .onAppear(perform: {
            if viewModel.account == nil {
                viewModel.getExternalLinkedBankAccount()
            } else {
                viewModel.loadEverydayAccountData()
            }
        })
        .padding(.top, 20)
        .padding(.horizontal, 22)
        .configureNavigationTitleZendaImage()
        .zendaAlert(item: $viewModel.retryAlert)
        .opacity(viewModel.initialLoad ? 0 : 1)
        .withLoadingIndicator(watching: $viewModel.showSpinner)
    }
    
    var fromAccount: some View {
        Text(viewModel.fromAccount)
            .font(Font.custom(.poppins, weight: .regular, size: 19, relativeTo: .headline))
            .foregroundColor(.onboardingTextFieldText)
            .leftAlign()
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
    
    var toAccount: some View {
        Text(viewModel.toAccount)
            .font(Font.custom(.poppins, weight: .regular, size: 19, relativeTo: .headline))
            .foregroundColor(.onboardingTextFieldText)
            .leftAlign()
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
    
    var totalAmount: some View {
        let view = HStack(spacing: 0) {
            if !viewModel.amount.isEmpty {
                Text("$")
                    .styled(.customFull(.poppins, .medium, 19, .leading, .secondaryText))
                    .padding(.trailing, 4)
            }
            
            ValidatedTextField(textValue: $viewModel.amount,
                               validationResult: $viewModel.amountValidationResult,
                               placeholder: "Enter amount $0.00",
                               isPlaceholderUppercased: false,
                               keyboardType: .decimalPad,
                               contentType: .none,
                               disableAutocorrection: true,
                               shouldDisplayValidationResult: $viewModel.shouldDisplayValidationResult, horizontalPadding: 0)
        }
        return view
    }
    
    func titleView(contentView: AnyView) -> some View {
            contentView
                .padding(.horizontal, 10)
                .frame(height: 47)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.onboardingBorder, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .withDoneButton()
    }
}

struct TransferFundsView_Previews: PreviewProvider {
    static var previews: some View {
        let account = Account(accountID: "4496209f-15ae-11ec-9ede-0242ac110002",
                              accountNumber: "1111222233330002",
                              routingNumber: "011401533",
                              bankName: "Coastal Federal Credit Union",
                              linkStatus: .linked,
                              ddaAccountNumber: "348101016643",
                              ddaRoutingNumber: "123456789")
        return TransferFundsView(viewModel: .init(goToSpecificView: false, account))
    }
}
