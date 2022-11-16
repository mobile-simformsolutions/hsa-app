//
//  HSAAppApplication.swift
//

import UIKit

class HSAAppApplication: UIApplication {
    
    // MARK: - Variable
    //
    private var idleTimer: Timer?

    // Resend the timer because there was user interaction
    func resetIdleTimer() {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }

        idleTimer = Timer.scheduledTimer(
            timeInterval: Constants.timeoutTreshold,
            target: self,
            selector: #selector(timeHasExceeded),
            userInfo: nil,
            repeats: false
        )
    }

    // If the timer reaches the limit as defined in timeoutInSeconds, post this notification
    @objc private func timeHasExceeded() {
        NotificationCenter.default.post(name: .appTimeout, object: nil)
    }

    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)

        if idleTimer != nil {
            self.resetIdleTimer()
        }

        if let touches = event.allTouches {
            for touch in touches where touch.phase == UITouch.Phase.began {
                self.resetIdleTimer()
            }
        }
    }

    override var preferredContentSizeCategory: UIContentSizeCategory {
        .large
    }
}
