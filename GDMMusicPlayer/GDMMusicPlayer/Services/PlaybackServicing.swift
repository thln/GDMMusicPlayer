//
//  PlaybackServiceProtocol.swift
//  GDMMusicPlayer
//
//  Created by Tam Nguyen on 11/10/25.
//
import Foundation

public protocol PlaybackEventsDelgate: AnyObject {
    func playbackService(_ service: PlaybackServicing, didUpdateState state:PlaybackState)
}


public protocol PlaybackServicing {
    var delegate: PlaybackEventsDelgate? { get set }
    func load(queue: [Track]) throws
    func play()
    func pause()
    func toggle()
    func seek(to seconds: TimeInterval)
    func skipNext()
    func skipPrevious()
    func toggleRepeatMode()
}
