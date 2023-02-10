//
//  AccountTransactionListView.swift
//

import SwiftUI

struct TransactionListView: View {
    
    // MARK: - Variables
    //
    let transactionSections: [TransactionSection]
    @Binding var listState: ListState
    let wrapInScrollView: Bool
    let emptyViewImage: Image?
    let emptyViewTitle: String
    let emptyViewSubTitle: String
    let onLoadMore: (() -> Void)?

    init(
        transactionSections: [TransactionSection],
        listState: Binding<ListState>,
        wrapInScrollView: Bool,
        emptyViewImage: Image?,
        emptyViewTitle: String,
        emptyViewSubTitle: String,
        onLoadMore: (() -> Void)?
    ) {
        self.transactionSections = transactionSections
        self._listState = listState
        self.wrapInScrollView = wrapInScrollView
        self.emptyViewImage = emptyViewImage
        self.emptyViewTitle = emptyViewTitle
        self.emptyViewSubTitle = emptyViewSubTitle
        self.onLoadMore = onLoadMore
    }

    var body: some View {
        transactionsList
    }
}

// MARK: - Sections

private extension TransactionListView {
    func sectionHeader(title: String) -> some View {
        HStack {
            Text(title.uppercased())
                .font(Font.custom(.poppins, weight: .medium, size: 15))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .background(Color.transactionDefault)
    }

    @ViewBuilder
    func transactionsSection(section: TransactionSection) -> some View {
        Section(header: sectionHeader(title: section.sectionName)) {
            if section.transactions.isEmpty {
                Text(appString.noTransactionYet())
                    .padding()
            } else {
                ForEach(section.transactions, id: \.id) { transaction in
                    transactionItem(for: transaction, in: section)
                        .onAppear {
                            if isLastItem(transaction: transaction, section: section) {
                                loadMoreIfNeeded()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 6)
                        .padding(.bottom, 4)
                        .id("\(section.id)_\(transaction.id)")
                }
            }
        }
    }

    func transactionItem(for transaction: TransactionSummaryDataModel, in section: TransactionSection) -> some View {
        VStack(spacing: 4) {
            TransactionSummaryView(transactionSummary: transaction)
            CustomDivider(color: section.transactions.isLastItem(transaction) ? .clear : Color.dividerBackground)
                .padding(.top, 8)
        }
    }

    func isLastItem(transaction: TransactionSummaryDataModel, section: TransactionSection) -> Bool {
        let isLastSection = transactionSections.isLastItem(section)

        guard isLastSection else {
            return false
        }

        return section.transactions.isLastItem(transaction)
    }

    func loadMoreIfNeeded() {
        guard let loadMore = onLoadMore else {
            return
        }

        if case let .items(moreAvailable) = listState {
            guard moreAvailable else {
                return
            }
            loadMore()
        }
    }
}

// MARK: - List

private extension TransactionListView {
    @ViewBuilder
    var transactionsList: some View {
        if !transactionSections.isEmpty {
            transactionsListView {
                ForEach(transactionSections) { section in
                    transactionsSection(section: section)
                }
            }
        } else {
            emptyStateView
        }
    }

    @ViewBuilder
    func transactionsListView<Content: View>(content: () -> Content) -> some View {
        if wrapInScrollView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, content: content)
                transactionFooterSection
            }
        } else {
            LazyVStack(alignment: .leading, spacing: 0, content: content)
            transactionFooterSection
        }
    }

    @ViewBuilder
    var transactionFooterSection: some View {
        switch listState {
        case .loading:
            Section(footer:
                HStack {
                    Spacer()
                    ActivityIndicator(isAnimating: .constant(true), style: .medium)
                Text(appString.loading()).styled(.customFull(.poppins, .medium, 18, .center, Color.navigationBackground))
                    Spacer()
                }.padding(.vertical)
            ) {}
        case let .items(moreAvailable):
            if let loadMore = onLoadMore, moreAvailable {
                let button = ActionButton(text: appString.loadMore()) {
                    loadMore()
                }
                .padding(10)

                Section(footer: button) {}
            }
        case let .error(error):
            Section(footer:
                HStack {
                    Spacer()
                Text(appString.failedToLoad(error.localizedDescription))
                    Spacer()
                }
            ) {}
        }

    }
}

// MARK: - Helpers

private extension TransactionListView {
    @ViewBuilder
    var loadingView: some View {
        HStack {
            Spacer()
            VStack {
                Text(appString.loading())
                    .styled(.customFull(.poppins, .medium, 15, .center, Color.navigationBackground))
                if #available(iOS 15.0, *) {
                    ProgressView()
                } else {
                    ActivityIndicator(isAnimating: .constant(true), style: .medium)
                }
            }
            Spacer()
        }
    }

    var emptyStateView: some View {
        VStack {
            if let emptyImage = emptyViewImage {
                TransactionListEmptyView(
                    title: emptyViewTitle,
                    image: emptyImage,
                    message: emptyViewSubTitle
                )
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            }
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        let transactions = Array(DashboardSummary.mockData().recentTransactions).map { TransactionSummaryDataModel(transactionSummary: $0) }
        let sections = TransactionSection.groupByMonth(transactions: transactions)

        let emptySections = [
            TransactionSection(sectionDate: Date().addingTimeInterval(99999), transactions: []),
            TransactionSection(sectionDate: Date().addingTimeInterval(999999999), transactions: [])
        ]

        let transactionSections = (sections + emptySections).sorted {
            $0.sectionDate > $1.sectionDate
        }

        return NavigationView {
            TransactionListView(
                transactionSections: transactionSections,
                listState: .constant(.items(moreAvailable: true)),
                wrapInScrollView: true,
                emptyViewImage: Image("CarouselPage1"),
                emptyViewTitle: appString.checkBackSoon(),
                emptyViewSubTitle: appString.youEmployerHasSetUp(),
                onLoadMore: { }
            )
        }
    }
}

/// Specifies the different states of an `AdvancedList`.
enum ListState: Equatable {
    /// The `error` state; displays the error view instead of the list to the user.
    case error(_ error: NSError)
    /// The `items` state (`default`); displays the items or the empty state view (if there are no items) to the user.
    case items(moreAvailable: Bool)
    /// The `loading` state; displays the loading state view instead of the list to the user.
    case loading
}
