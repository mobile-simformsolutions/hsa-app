//
//  PullToRefresh.swift
//

import SwiftUI
import Introspect

private struct PullToRefresh: UIViewRepresentable {
    
    @Binding var isShowing: Bool
    let onRefresh: () -> Void
    
    public init(
        isShowing: Binding<Bool>,
        onRefresh: @escaping () -> Void
    ) {
        _isShowing = isShowing
        self.onRefresh = onRefresh
    }
    
    public class Coordinator {
        let onRefresh: () -> Void
        let isShowing: Binding<Bool>
        
        init(
            onRefresh: @escaping () -> Void,
            isShowing: Binding<Bool>
        ) {
            self.onRefresh = onRefresh
            self.isShowing = isShowing
        }
        
        @objc
        func onValueChanged() {
//            isShowing.wrappedValue = true
            onRefresh()
        }
    }
    
    public func makeUIView(context: UIViewRepresentableContext<PullToRefresh>) -> UIView {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }
    
    private func scrollView(entry: UIView) -> UIScrollView? {
        
        // Search in ancestors
        if let scrollView = entry as? UIScrollView {
            return scrollView
        }
        if let scrollView = Introspect.findAncestor(ofType: UIScrollView.self, from: entry) {
            return scrollView
        }

        guard let viewHost = Introspect.findViewHost(from: entry) else {
            return nil
        }

        // Search in siblings
        return Introspect.previousSibling(containing: UIScrollView.self, from: viewHost)
    }

    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PullToRefresh>) {
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            
            guard let scrollView = self.scrollView(entry: uiView) else {
                return
            }
            
            if let refreshControl = scrollView.refreshControl {
                if self.isShowing {
                    if refreshControl.isRefreshing == false {
                        refreshControl.beginRefreshing()
                    }
                } else {
                    refreshControl.endRefreshing()
                }
                return
            }
            
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.onValueChanged), for: .valueChanged)
            scrollView.refreshControl = refreshControl
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(onRefresh: onRefresh, isShowing: $isShowing)
    }
}

public extension View {
    func pullToRefresh(isShowing: Binding<Bool>, onRefresh: @escaping () -> Void) -> some View {
        return overlay(
            PullToRefresh(isShowing: isShowing, onRefresh: onRefresh)
                .frame(width: 0, height: 0)
        )
    }
}

// struct PullToRefresh: View {
//
//    var coordinateSpaceName: String
//    var onRefresh: ()->Void
//
//    @State var needRefresh: Bool = false
//
//    var body: some View {
//        GeometryReader { geo in
//            if (geo.frame(in: .named(coordinateSpaceName)).midY > 50) {
//                Spacer()
//                    .onAppear {
//                        needRefresh = true
//                    }
//            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 10) {
//                Spacer()
//                    .onAppear {
//                        if needRefresh {
//                            needRefresh = false
//                            onRefresh()
//                        }
//                    }
//            }
//            HStack {
//                Spacer()
//                if needRefresh {
//                    VStack {
//                    Spacer.large()
//                    Spacer.large()
//                    Spacer.large()
//                    Spacer.large()
//                    Spacer.large()
//                    Spacer.large()
//                    Text("Refreshing")
//                    Spacer.large()
//                    }.padding(.top, 50)
//                } else {
//                    Text("⬇️")
//                }
//                Spacer()
//            }
//        }.padding(.top, -50)
//    }
// }
