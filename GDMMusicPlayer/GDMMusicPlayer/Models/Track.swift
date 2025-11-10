//
//  Track.swift
//  GDMMusicPlayer
//
//  Created by Tam Nguyen on 11/10/25.
//
import Foundation

public struct Track {
    // would include id in non mock code
    let title: String
    let artist: String
    let duration: TimeInterval
    let artworkSource: ArtworkSource?
    
    public init(title: String,
                artist: String,
                duration: TimeInterval,
                artworkSource: ArtworkSource? = nil) {
        self.title = title
        self.artist = artist
        self.duration = duration
        self.artworkSource = artworkSource
    }
}
