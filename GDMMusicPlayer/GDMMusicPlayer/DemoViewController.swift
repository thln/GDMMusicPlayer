//
//  ViewController.swift
//  GDMMusicPlayer
//
//  Created by Tam Nguyen on 11/10/25.
//

import UIKit

class DemoViewController: UIViewController {
    
    private var playerView: MediumPlayerView!
    private let service = MockPlaybackService()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .systemBackground
        let playerViewModel = PlayerViewModel(service: service)
        playerView = MediumPlayerView(viewModel: playerViewModel)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)
        
        NSLayoutConstraint.activate([
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
        
        playerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
        
        let demo: [Track] = [
            Track(title: "Bad Habit", artist: "Steve Lacy", duration: 232, artworkSource: ArtworkSource.asset("mock_album_artwork_bad_habit")),
            Track(title: "Black Friday (pretty like the sun)", artist: "Lost Frequencies, Tom Odell, Poppy Baskcomb", duration: 311),
            Track(title: "Shouldn't Couldn't Wouldn't", artist: "88 rising, NIKI, Rich Brian", duration: 195, artworkSource: ArtworkSource.asset("mock_album_artwork_shouldnt_couldnt_wouldnt"))
        ]
        
        try? service.load(queue:demo)
        service.play()
    }


}

