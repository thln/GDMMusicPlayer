//
//  MediumPlayerView.swift
//  GDMMusicPlayer
//
//  Created by Tam Nguyen on 11/10/25.
//

import UIKit

final class MediumPlayerView: UIView, PlayerViewModelDelegate {
    private enum Layout {
        static let DEFAULT_ARTWORK_NAME = "music.note"
        
        static let PAUSE_BUTTON_NAME = "pause.fill"
        static let PLAY_BUTTON_NAME = "play.fill"
        static let REPEAT_BUTTON_NAME = "repeat"
        static let REPEAT_ONE_BUTTON_NAME = "repeat.1"
        static let PREV_BUTTON_NAME = "backward.end.fill"
        static let NEXT_BUTTON_NAME = "forward.end.fill"
        static let LIKE_BUTTON_EMPTY_NAME = "heart"
        static let LIKE_BUTTON_FILLED_NAME = "heart.fill"
        
        static let TIME_FONT_SIZE: CGFloat = 12
        static let TEXT_PADDING: CGFloat = 6
        static let ARTWORK_TO_TEXT_PADDING: CGFloat = 16
        static let SLIDER_PADDING: CGFloat = 6
        static let CONTROL_BUTTON_SPACING: CGFloat = 16
        
        static let VIEW_SPACING : CGFloat = 16
    }

    private let container = UIView()
    private let artworkView = UIImageView()
    private let titleLabel = RotatingLabel()
    private let subtitleLabel = RotatingLabel()
    private let slider = UISlider()
    private let elapsedLabel = UILabel()
    private let durationLabel = UILabel()
    
    private let repeatButton = UIButton(type: .system)
    private let previousButton = UIButton(type: .system)
    private let playPauseButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let likeButton = UIButton(type: .system)
    
    private lazy var doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
    private lazy var leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
    private lazy var rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
    
    private var showRemaining = false
    private var currState: PlayerViewState = .empty
    private var lastLiked: Bool?
    
    private let viewModel: PlayerViewModel
    
    init(viewModel: PlayerViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        viewModel.delegate = self
        setupUI()
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        container.backgroundColor = PlayerDesignSpecs.backgroundColor
        container.layer.cornerRadius = PlayerDesignSpecs.cornerRadius
        container.layer.masksToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        
        artworkView.contentMode = .scaleAspectFill
        artworkView.layer.cornerRadius = PlayerDesignSpecs.artworkCornerRadius
        artworkView.clipsToBounds = true
        artworkView.tintColor = .white
        artworkView.image = UIImage(systemName: Layout.DEFAULT_ARTWORK_NAME)
        artworkView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            artworkView.widthAnchor.constraint(equalToConstant: PlayerDesignSpecs.artworkSize),
            artworkView.heightAnchor.constraint(equalToConstant: PlayerDesignSpecs.artworkSize)
        ])
        
        titleLabel.font = PlayerDesignSpecs.titleFont
        titleLabel.numberOfLines = 1
        titleLabel.textColor = PlayerDesignSpecs.titleColor
        titleLabel.isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(copyTitle))
        titleLabel.addGestureRecognizer(longPress)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        subtitleLabel.font = PlayerDesignSpecs.subtitleFont
        subtitleLabel.textColor = PlayerDesignSpecs.subtitleColor
        subtitleLabel.numberOfLines = 1
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = Layout.TEXT_PADDING
        
        let infoStack = UIStackView(arrangedSubviews: [artworkView, textStack])
        infoStack.axis = .horizontal
        infoStack.alignment = .center
        infoStack.spacing = Layout.ARTWORK_TO_TEXT_PADDING
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        let minImg = trackImage(color: PlayerDesignSpecs.timelinePrimaryColor, height:PlayerDesignSpecs.sliderTrackHeight)
        let maxImg = trackImage(color: PlayerDesignSpecs.timelineSecondaryColor, height:PlayerDesignSpecs.sliderTrackHeight)
        slider.setMinimumTrackImage(minImg, for: .normal)
        slider.setMaximumTrackImage(maxImg, for: .normal)
        slider.setThumbImage(thumbImage(diameter: PlayerDesignSpecs.sliderThumbDiameter, color: .white), for: .normal)
        
        elapsedLabel.font = .monospacedSystemFont(ofSize: Layout.TIME_FONT_SIZE, weight: .regular)
        elapsedLabel.textColor = .white
        elapsedLabel.text = "0:00"
        elapsedLabel.textAlignment = .left
        durationLabel.font = elapsedLabel.font
        durationLabel.textColor = .white
        durationLabel.text = "0:00"
        durationLabel.textAlignment = .right
        durationLabel.isUserInteractionEnabled = true
        durationLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleRemaining)))
        
        let times = UIStackView(arrangedSubviews: [elapsedLabel, UIView(), durationLabel])
        times.axis = .horizontal
        times.alignment = .center
        
        let timelineStack = UIStackView(arrangedSubviews: [slider, times])
        timelineStack.axis = .vertical
        timelineStack.spacing = Layout.SLIDER_PADDING
        
        repeatButton.setImage(UIImage(systemName: Layout.REPEAT_BUTTON_NAME), for: .normal)
        previousButton.setImage(UIImage(systemName: Layout.PREV_BUTTON_NAME), for: .normal)
        nextButton.setImage(UIImage(systemName: Layout.NEXT_BUTTON_NAME), for: .normal)
        likeButton.setImage(UIImage(systemName: Layout.LIKE_BUTTON_EMPTY_NAME), for: .normal)
        
        repeatButton.tintColor = .white
        previousButton.tintColor = .white
        nextButton.tintColor = .white
        likeButton.tintColor = .white
        
        [repeatButton, previousButton, nextButton, likeButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: PlayerDesignSpecs.secondaryButtonSize),
                button.heightAnchor.constraint(equalToConstant: PlayerDesignSpecs.secondaryButtonSize)
            ])
            button.layer.cornerRadius = PlayerDesignSpecs.secondaryButtonSize/2
        }
        
        playPauseButton.tintColor = .white
        playPauseButton.backgroundColor = PlayerDesignSpecs.selectedColor
        playPauseButton.layer.cornerRadius = PlayerDesignSpecs.playButtonSize/2
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        playPauseButton.setContentHuggingPriority(.required, for: .horizontal)
        
        let playContainer = UIView()
        playContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playContainer.widthAnchor.constraint(equalToConstant: PlayerDesignSpecs.playButtonSize),
            playContainer.heightAnchor.constraint(equalToConstant: PlayerDesignSpecs.playButtonSize)
        ])
        playContainer.addSubview(playPauseButton)
        
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: playContainer.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: playContainer.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: PlayerDesignSpecs.playButtonSize),
            playPauseButton.heightAnchor.constraint(equalToConstant: PlayerDesignSpecs.playButtonSize)
        ])
        
        repeatButton.addTarget(self, action: #selector(repeatTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)

        
        let controlStack = UIStackView(arrangedSubviews: [repeatButton, previousButton, playContainer, nextButton, likeButton])
        controlStack.axis = .horizontal
        controlStack.alignment = .center
        controlStack.spacing = Layout.CONTROL_BUTTON_SPACING
        controlStack.distribution = .equalSpacing
        
        let overallStack = UIStackView(arrangedSubviews: [infoStack, timelineStack, controlStack])
        overallStack.axis = .vertical
        overallStack.spacing = Layout.VIEW_SPACING
        overallStack.layoutMargins = UIEdgeInsets(top: PlayerDesignSpecs.contentPadding, left: PlayerDesignSpecs.contentPadding, bottom: PlayerDesignSpecs.contentPadding, right: PlayerDesignSpecs.contentPadding)
        overallStack.isLayoutMarginsRelativeArrangement = true
        overallStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(overallStack)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            overallStack.topAnchor.constraint(equalTo: container.topAnchor),
            overallStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            overallStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            overallStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        
        // Overall Gestures
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        leftSwipe.direction = .left
        addGestureRecognizer(leftSwipe)
        rightSwipe.direction = .right
        addGestureRecognizer(rightSwipe)
        
        updatePlayPauseIcon(isPlaying: false)
        configureAccessibility()
    }
    
    private func repeatName(for mode: RepeatMode) -> String {
        switch mode {
        case .off, .all: return Layout.REPEAT_BUTTON_NAME
        case .one: return Layout.REPEAT_ONE_BUTTON_NAME
        }
    }
    
    private func configureAccessibility() {
        isAccessibilityElement = false
        artworkView.isAccessibilityElement = true
        artworkView.accessibilityLabel = "Album artwork"
        titleLabel.isAccessibilityElement = true
        titleLabel.accessibilityTraits = .staticText
        subtitleLabel.isAccessibilityElement = true
        subtitleLabel.accessibilityTraits = .staticText
        slider.isAccessibilityElement = true
        slider.accessibilityTraits = .adjustable
        repeatButton.accessibilityLabel = "Repeat"
        previousButton.accessibilityLabel = "Previous"
        nextButton.accessibilityLabel = "Next"
        playPauseButton.accessibilityLabel = "Play"
        likeButton.accessibilityLabel = "Like"
    }
    
    func playerViewModel(_ viewModel: PlayerViewModel, didUpdateState state: PlayerViewState) {
        let previousState = currState
        currState = state
        
        if previousState.title != state.title {
            titleLabel.text = state.title
        }
        if previousState.subtitle != state.subtitle {
            subtitleLabel.text = state.subtitle
        }
        slider.setValue(state.progress, animated: true)
        elapsedLabel.text = state.elapsedText
        updateDurationLabel(state: state)
        updatePlayPauseIcon(isPlaying: state.isPlaying)
        
        let active = (state.repeatMode != .off)
        let repeatName = repeatName(for: state.repeatMode)
        repeatButton.setImage(UIImage(systemName: repeatName), for: .normal)
        repeatButton.tintColor = .white
        repeatButton.backgroundColor = active ? PlayerDesignSpecs.selectedColor : .clear
        repeatButton.layer.cornerRadius = PlayerDesignSpecs.secondaryButtonSize/2
        
        if let last = lastLiked, last != state.isLiked {
            setLikeAppearance(liked: state.isLiked, animated: true)
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } else {
            setLikeAppearance(liked: state.isLiked, animated: false)
        }
        lastLiked = state.isLiked
        
        slider.accessibilityValue = "\(Int(state.progress * 100)) percent"
        playPauseButton.accessibilityLabel = state.isPlaying ? "Pause" : "Play"
        repeatButton.accessibilityLabel = {
            switch state.repeatMode {
            case .off: return "Repeat Off"
            case .one: return "Repeat One"
            case .all: return "Repeat On"
            }
        }()
        
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
    
    func playerViewModel(_ viewModel: PlayerViewModel, didUpdateArtwork image: UIImage?) {
        if let image {
            artworkView.image = image
            artworkView.contentMode = .scaleAspectFill
        } else {
            artworkView.image = UIImage(systemName: Layout.DEFAULT_ARTWORK_NAME)
            artworkView.contentMode = .scaleAspectFit
        }
    }
    
    private func updateDurationLabel(state: PlayerViewState) {
        if showRemaining {
            let remaining = max(state.duration - state.currentTime, 0)
            durationLabel.text = "-" + Self.mmss(remaining)
        } else {
            durationLabel.text = state.durationText
        }
    }
    
    private static func mmss(_ t: TimeInterval) -> String {
        let total = Int(t.rounded())
        return "\(total/60):" + String(format: "%02d", total % 60)
    }
    
    private func updatePlayPauseIcon(isPlaying: Bool) {
        playPauseButton.setImage(UIImage(systemName: isPlaying ? Layout.PAUSE_BUTTON_NAME : Layout.PLAY_BUTTON_NAME), for:.normal)
        playPauseButton.imageView?.contentMode = .scaleAspectFit
        playPauseButton.tintColor = .white
    }

    private func setLikeAppearance(liked: Bool, animated: Bool) {
        let likeAnimations = {
            self.likeButton.setImage(UIImage(systemName: liked ? Layout.LIKE_BUTTON_FILLED_NAME : Layout.LIKE_BUTTON_EMPTY_NAME), for:.normal)
            self.likeButton.tintColor = liked ? .systemRed : .white
        }
        if animated {
            UIView.transition(with: likeButton, duration: 0.18, options: .transitionCrossDissolve, animations: likeAnimations)
            UIView.animateKeyframes(withDuration: 0.35, delay: 0, options: [.calculationModeCubic], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.3) { self.likeButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25) }
                UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7) { self.likeButton.transform = .identity }
            })
        } else {
            likeAnimations()
        }
    }
    
    private func trackImage(color: UIColor, height: CGFloat) -> UIImage {
        let size = CGSize(width: 2, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: height/2)
        color.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1))
    }
    
    private func thumbImage(diameter: CGFloat, color: UIColor) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(ovalIn: rect)
        color.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    @objc private func sliderChanged() {
        viewModel.seek(to: slider.value)
    }
    
    @objc private func playPauseTapped() {
        viewModel.playPauseTapped()
    }
    
    @objc private func prevTapped() {
        viewModel.prevTapped()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    @objc private func nextTapped() {
        viewModel.nextTapped()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    @objc private func likeTapped() {
        viewModel.likeTapped()
    }
    
    @objc private func repeatTapped() {
        viewModel.repeatTapped()
    }
    
    @objc private func toggleRemaining() {
        showRemaining.toggle()
        updateDurationLabel(state: currState)
    }
    
    @objc private func copyTitle(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        UIPasteboard.general.string = titleLabel.text
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    @objc private func handleDoubleTap() {
        likeTapped()
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            nextTapped()
        } else if gesture.direction == .right {
            prevTapped()
        }
    }
}
