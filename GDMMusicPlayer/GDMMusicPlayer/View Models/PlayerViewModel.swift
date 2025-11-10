//
//  PlayerViewModel.swift
//  GDMMusicPlayer
//
//  Created by Tam Nguyen on 11/10/25.
//

import UIKit

public struct PlayerViewState: Equatable {
    public var title: String
    public var subtitle: String
    public var progress: Float
    public var elapsedText: String
    public var durationText: String
    public var isPlaying: Bool
    public var repeatMode: RepeatMode
    public var isLiked: Bool
    public var currentTime: TimeInterval
    public var duration: TimeInterval
    
    public static let empty = PlayerViewState(
        title: "",
        subtitle: "",
        progress: 0,
        elapsedText: "0:00",
        durationText: "0:00",
        isPlaying: false,
        repeatMode: .off,
        isLiked: false,
        currentTime: 0,
        duration: 0
    )
}

public protocol PlayerViewModelDelegate: AnyObject {
    func playerViewModel(_ viewModel: PlayerViewModel, didUpdateState state: PlayerViewState)
    func playerViewModel(_ viewModel: PlayerViewModel, didUpdateArtwork image: UIImage?)
}

public final class PlayerViewModel: PlaybackEventsDelgate {
    weak var delegate: PlayerViewModelDelegate?
    
    private var service: PlaybackServicing
    
    private var like = false
    
    private var lastServiceState = PlaybackState(currentTrack: nil, isPlaying: false, currentTime: 0, duration: 0, repeatMode: .off)
    
    private(set) var state: PlayerViewState = .empty {
        didSet {
            if state != oldValue { delegate?.playerViewModel(self, didUpdateState: state) }
        }
    }
    
    init(service: PlaybackServicing) {
        self.service = service
        self.service.delegate = self
    }
    
    // View Inputs
    func playPauseTapped() {
        service.toggle()
    }
    
    func nextTapped() {
        service.skipNext()
    }
    
    func prevTapped() {
        service.skipPrevious()
    }
    
    func seek(to value: Float) {
        service.seek(to: Double(value) * lastServiceState.duration)
    }
    
    func likeTapped() {
        like.toggle()
        // USE STATE LIKE?
        emitState()
    }
    
    func repeatTapped() {
        service.toggleRepeatMode()
    }
    
    public func playbackService(_ service: PlaybackServicing, didUpdateState state: PlaybackState) {
        if Thread.isMainThread {
            apply(state)
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.apply(state)
            }
        }
    }
    
    @MainActor
    public func apply(_ state: PlaybackState) {
        lastServiceState = state
        if case let .asset(assetName) = state.currentTrack?.artworkSource {
            delegate?.playerViewModel(self, didUpdateArtwork: UIImage(named: assetName))
        } else {
            delegate?.playerViewModel(self, didUpdateArtwork: nil)
        }
        emitState()
    }
    
    private func emitState() {
        let title = lastServiceState.currentTrack?.title ?? ""
        let subtitle = lastServiceState.currentTrack?.artist ?? ""
        let progress: Float = {
            guard lastServiceState.duration > 0 else { return 0 }
            return Float(lastServiceState.currentTime / lastServiceState.duration)
        }()
        self.state = PlayerViewState(title: title,
                                subtitle: subtitle,
                                progress: progress,
                                elapsedText: Self.mmss(lastServiceState.currentTime),
                                durationText: Self.mmss(lastServiceState.duration),
                                isPlaying: lastServiceState.isPlaying,
                                repeatMode: lastServiceState.repeatMode,
                                isLiked: like,
                                     currentTime: lastServiceState.currentTime,
                                     duration: lastServiceState.duration)
    }
    
    private static func mmss(_ t: TimeInterval) -> String {
        let total = Int(t.rounded())
        let (m, s) = total.quotientAndRemainder(dividingBy: 60)
        return String(format: "%d:%02d", m, s)
    }
}
