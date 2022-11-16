//
//  ProgressBar.swift
//

import SwiftUI

struct ProgressBarView: Animatable, View {
    /// Between 0 - 100
    ///
    private var progress: CGFloat
    private let backgroundColor: Color
    private var foregroundColor: Color
    private var innerPadding: CGFloat = 4
    private let animationTimeInterval: TimeInterval = 1

    init(progress: CGFloat, foregroundColor: Color, backgroundColor: Color = .clear) {
        self.progress = min(progress, 100)
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    private func cornerRadius(from height: CGFloat) -> CGFloat {
        height / 2
    }

    private func needsToBeFilledArea(totalArea: CGFloat) -> CGFloat {
        (totalArea - innerPadding * 2) * progress / 100
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius(from: geometry.size.height))
                    .fill(backgroundColor)
                    .frame(width: geometry.size.width, height: geometry.size.height)

                RoundedRectangle(cornerRadius: cornerRadius(from: geometry.size.height))
                    .fill(foregroundColor)
                    .frame(width: needsToBeFilledArea(totalArea: geometry.size.width), height: geometry.size.height - innerPadding * 2)
                    .offset(x: innerPadding)
            }
        }
    }

}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressBarView(progress: 20, foregroundColor: .transactionPositive, backgroundColor: .white)
                .frame(height: 30)
        }
        .background(Color.gray)
        .padding()
    }
}
