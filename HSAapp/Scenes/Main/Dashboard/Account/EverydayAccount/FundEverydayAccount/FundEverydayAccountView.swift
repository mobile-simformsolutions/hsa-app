//
//  FundEverydayAccountView.swift

import SwiftUI

struct FundEverydayAccountView: View {
    @ObservedObject var viewModel: FundEverydayAccountViewModel

    var body: some View {
        if viewModel.openAccountLinkingView {
            LinkAccountView(showLinkAccount: $viewModel.openAccountLinkingView)
        } else {
            if let account = viewModel.account {
                NavigationLink(
                    destination: TransferFundsView(viewModel: .init(goToSpecificView: viewModel.goToSpecificView, account)
                    ),
                    isActive: $viewModel.oneTimeDeposit,
                    label: { EmptyView() }
                )
                .isDetailLink(false)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer.medium()
                    Text(viewModel.title)
                        .styled(.customFull(.poppins, .medium, 26, .leading, .primaryText))
                    Spacer.small()
                    Text(viewModel.subtitle)
                        .styled(.customFull(.openSans, .regular, 15, .leading, .secondaryText))
                    Spacer.medium()
                    AccountNumbersView(routingNumber: viewModel.ddaRoutingNumber, accountNumber: viewModel.ddaAccountNumber)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Spacer.medium()
                    Text(viewModel.bankInformationTitle)
                        .styled(.customFull(.poppins, .medium, 22, .leading, .secondaryText))
                        .multilineTextAlignment(.leading)
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(viewModel.bankInformation)
                                .styled(.customFull(.openSans, .regular, 15, .leading, .secondaryText))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 0) {
                            Text(viewModel.linkStatus)
                                .styled(.customFull(.openSans, .regular, 15, .leading, .secondaryText))
                            Spacer.small()
                            Image(viewModel.linkImageName).styled(.cellRight).onTapGesture {
                                viewModel.showUnlinkExternalAccountAlert()
                            }
                        }
                    }
                    Spacer.medium()
                    Divider().style(.list)
                }
                Button {
                    viewModel.oneTimeDepositPressed()
                } label: {
                    VStack {
                        Spacer.medium()
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(viewModel.oneTimeDepositTitle)
                                    .styled(.customFull(.poppins, .medium, 22, .leading, .secondaryText))
                                Text(viewModel.oneTimeDepositSubTitle)
                                    .styled(.customFull(.openSans, .regular, 15, .leading, .secondaryText))
                            }
                            Spacer()
                            Image(systemName: "chevron.forward").resizable()
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color.defaultBackground)
                                .frame(width: 18, height: 18, alignment: .center)
                        }
                        Spacer.medium()
                        Divider().style(.list)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            .background(Color.darkBackground.edgesIgnoringSafeArea(.all))
            .opacity((viewModel.showSpinner && viewModel.account == nil) ? 0 : 1)
            .withLoadingIndicator(watching: $viewModel.showSpinner)
            .configureNavigationTitleZendaImage()
            .isDisabled(viewModel.showSpinner)
            .zendaAlert(item: $viewModel.alertToShow)
            .onAppear {
                if !viewModel.accountLinked, !viewModel.isInitialLoad {
                    viewModel.getExternalLinkedBankAccount()
                }
            }
        }
    }
}

struct FundEverydayAccountView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = FundEverydayAccountViewModel(goToSpecificView: true, accountType: .everyday)
        return FundEverydayAccountView(viewModel: viewModel)
    }
}
