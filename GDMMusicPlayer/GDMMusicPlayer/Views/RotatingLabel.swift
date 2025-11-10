//
//  RotatingLabel.swift
//  GDMMusicPlayer
//
//  Created by Tam Nguyen on 11/10/25.
//

import UIKit

class RotatingLabel: UILabel {
    private enum Constants {
        static let STEP_INTERVAL: TimeInterval = 0.15
        static let PAUSE_LENGTH_AT_START: TimeInterval = 2.0
    }
    private var timer: Timer?
    private var original: String = ""
    private var index: Int = 0
    private var lastMeasuredWidth: CGFloat = .zero
    private var isRunning = false
    
    override var text: String? {
        didSet {
            guard text != oldValue else { return }
            original = text ?? ""
            index = 0
            evaluateOverflowAndStartIfNeeded(force: true)
        }
    }
    
    deinit {
        stop()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if abs(bounds.width - lastMeasuredWidth) > 0.5 {
            lastMeasuredWidth = bounds.width
            evaluateOverflowAndStartIfNeeded(force: false)
        }
    }
    
    private func evaluateOverflowAndStartIfNeeded(force: Bool) {
        guard !original.isEmpty else { stop();  return }
        let widthNeeded = (original as NSString).size(withAttributes: [.font : font as Any]).width
        let shouldScroll = widthNeeded > bounds.width
        
        if shouldScroll {
            if force || !isRunning {
                start(after: Constants.PAUSE_LENGTH_AT_START)
            }
        } else {
            stop()
            super.text = original
        }
    }
    
    private func start(after delay: TimeInterval) {
        stop()
        isRunning = true
        let newTimer = Timer(timeInterval: Constants.STEP_INTERVAL, repeats: true) { [weak self] _ in
            self?.tick()
        }
        newTimer.tolerance = Constants.STEP_INTERVAL * 0.2
        RunLoop.main.add(newTimer, forMode: .common)
        newTimer.fireDate = Date().addingTimeInterval(delay)
        timer = newTimer
    }
    
    private func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    private func tick() {
        guard !original.isEmpty else { return }
        if index == 0 { super.text = original }
        index = (index + 1).quotientAndRemainder(dividingBy: original.count).remainder
        super.text = rotate(original, by: index)
        if index == 0 {
            timer?.fireDate = Date().addingTimeInterval(Constants.PAUSE_LENGTH_AT_START)
        }
    }
    
    private func rotate(_ s: String, by n: Int) -> String {
        guard n > 0, n < s.count else { return s }
        let i = s.index(s.startIndex, offsetBy: n)
        return String(s[i...]) + " " + String(s[..<i])
    }
}
