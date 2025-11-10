//
//  PlaybackTypes.swift
//  GDMMusicPlayer
//
//  Created by Tam Nguyen on 11/10/25.
//
import Foundation

public enum RepeatMode: Equatable {
    case off
    case one
    case all
}

public enum PlaybackError: Error {
    case loadFailed
    case emptyQueue
}

public struct PlaybackState {
    public var currentTrack: Track?
    public var isPlaying: Bool
    public var currentTime: TimeInterval
    public var duration: TimeInterval
    public var repeatMode: RepeatMode
}
