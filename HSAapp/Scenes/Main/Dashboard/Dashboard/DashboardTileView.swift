//
//  DashboardTileView.swift
//

import SwiftUI
import RealmSwift

struct DashboardTileView: View {
    
    @ObservedObject var viewModel: DashboardTileViewModel
    var onButtonTap: () -> Void
    
    var body: some View {
        HStack {
            VStack {
                Spacer()
                Image(viewModel.imageName)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.defaultText)
                    .background(Color.clear)
                    .frame(width: 31, height: 31, alignment: .center)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 20)
                Spacer()
            }.background(viewModel.imageBackgroundColor)
            Spacer.medium()

            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.title)
                    .styled(.customFull(.poppins, .medium, 16, .leading, Color.secondaryText))
                    .minimumScaleFactor(0.4)
                Text(viewModel.subtitle)
                    .styled(.customFull(.poppins, .regular, 13, .leading, Color.secondaryText))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 0) {
                if let accountSummary = viewModel.accountSummary {
                    if accountSummary.amount > 0 {
                        Text(viewModel.displayAmount)
                            .styled(.custom(.poppins, .semiBold, 16)).multilineTextAlignment(.trailing)
                    }
                }
                Spacer.small()
                Image(systemName: "chevron.forward").resizable()
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.defaultBackground)
                    .frame(width: 16, height: 16, alignment: .center)
            }
            Spacer.medium()
        }
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.onboardingBorder.opacity(0.7), lineWidth: 1)
        )
        .background(
            Color.lightBackground
                .cornerRadius(6)
                .shadow(color: .gray.opacity(0.7), radius: 5, x: 0, y: 3)
        )
        .onTapGesture(perform: onButtonTap)
    }
}

struct DashboardTileView_Previews: PreviewProvider {
    static var previews: some View {
        let accountSummary = AccountSummary()
        accountSummary._id = ObjectId.generate()
        accountSummary.amount = 123.11
        accountSummary.status = .active
        accountSummary.type = .everyday
        let viewModel = DashboardTileViewModel(accountSummary: AccountSummaryDataModel(accountSummary: accountSummary))
        
        let accountSummary2 = AccountSummary()
        accountSummary2._id = ObjectId.generate()
        accountSummary2.amount = 12300.11
        accountSummary2.status = .suspended
        accountSummary.type = .hsa
        let viewModel2 = DashboardTileViewModel(accountSummary: AccountSummaryDataModel(accountSummary: accountSummary2))
        
        return Group {
            DashboardTileView(viewModel: viewModel, onButtonTap: {})
            DashboardTileView(viewModel: viewModel2, onButtonTap: {})
                .previewDevice("iPhone SE (2nd generation)")
        }.previewLayout(.device)
    }
}
