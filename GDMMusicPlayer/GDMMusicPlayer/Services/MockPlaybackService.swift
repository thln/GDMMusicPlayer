//
//  MockPlaybackService.swift
//  GDMMusicPlayer
//
//  Created by Tam Nguyen on 11/10/25.
//
import Foundation

final class MockPlaybackService: PlaybackServicing {
    private enum Constants {
        static let ADVANCE_UP_ONE: Int = 1
        static let ADVANCE_DOWN_ONE: Int = -1
        static let MAX_DURATION_SKIP_PREV: TimeInterval = 3
        static let REFRESH_RATE: TimeInterval = 1.0/30.0
    }
    
    weak var delegate: PlaybackEventsDelgate?
    
    private var queue: [Track] = []
    private var queueIndex = 0
    private var timer: Timer?
    private var state = PlaybackState(currentTrack: nil, isPlaying: false, currentTime: 0, duration: 0, repeatMode: .off)
    
    func load(queue: [Track]) throws {
        guard !queue.isEmpty else { throw PlaybackError.emptyQueue }
        self.queue = queue
        queueIndex = 0
        let currTrack = queue[queueIndex]
        state = .init(currentTrack: currTrack, isPlaying: false, currentTime: 0, duration: currTrack.duration, repeatMode: state.repeatMode)
        notify()
    }
    
    func play() {
        guard !queue.isEmpty else { return }
        if state.currentTrack == nil {
            queueIndex = 0
            let newTrack = queue[queueIndex]
            state = .init(currentTrack: newTrack, isPlaying: true, currentTime: 0, duration: newTrack.duration, repeatMode: state.repeatMode)
        }
        state.isPlaying = true
        notify()
        start()
    }
    
    func pause() {
        state.isPlaying = false
        notify()
        stop()
    }
    
    func toggle() {
        state.isPlaying ? pause() : play()
    }
    
    func seek(to seconds: TimeInterval) {
        state.currentTime = max(0, min(seconds, state.duration))
        notify()
        
    }
    
    func skipNext() {
        advance(by:Constants.ADVANCE_UP_ONE)
    }
    
    func skipPrevious() {
        advance(by:Constants.ADVANCE_DOWN_ONE)
    }
    
    func toggleRepeatMode() {
        switch state.repeatMode {
        case .off: state.repeatMode = .all
        case .all: state.repeatMode = .one
        case .one: state.repeatMode = .off
        }
        notify()
    }
    
// MARK: Private
    private func advance(by delta: Int) {
        guard !queue.isEmpty else { return }
        
        if delta == Constants.ADVANCE_DOWN_ONE
                && state.currentTime > Constants.MAX_DURATION_SKIP_PREV {
            restartTrack()
            return
        }
                    
        switch state.repeatMode {
        case .one:
            restartTrack()
        case .all:
            queueIndex = (queueIndex + delta + queue.count) % queue.count
            let newTrack = queue[queueIndex]
            state = .init(currentTrack: newTrack, isPlaying: state.isPlaying, currentTime: 0, duration: newTrack.duration, repeatMode: state.repeatMode)
            notify()
        case .off:
            let newIndex = queueIndex + delta
            if newIndex == -1 {
                restartTrack()
            } else if newIndex == queue.count {
                state = PlaybackState(currentTrack: nil, isPlaying: false, currentTime: 0, duration: 0, repeatMode: .off)
                notify()
            } else {
                queueIndex = newIndex
                let newTrack = queue[queueIndex]
                state = .init(currentTrack: newTrack, isPlaying: state.isPlaying, currentTime: 0, duration: newTrack.duration, repeatMode: state.repeatMode)
                notify()
            }
            
        }
    }
    
    private func restartTrack() {
        state.currentTime = 0
        notify()
    }
    
    private func notify() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.playbackService(self, didUpdateState: self.state)
        }
    }
    
    private func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: Constants.REFRESH_RATE, repeats: true) { [weak self] _ in
            guard let self = self, self.state.isPlaying else { return }
            self.state.currentTime += Constants.REFRESH_RATE
            if self.state.currentTime >= self.state.duration {
                self.advance(by: Constants.ADVANCE_UP_ONE)
            } else {
                self.notify()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func stop() {
        timer?.invalidate()
        timer = nil
    }
    
}

