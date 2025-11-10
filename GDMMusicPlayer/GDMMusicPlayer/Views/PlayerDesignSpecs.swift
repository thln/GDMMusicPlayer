//
//  PlayerDesignSpecs.swift
//  GDMMusicPlayer
//
//  Created by Tam Nguyen on 11/10/25.
//

import UIKit

public enum PlayerDesignSpecs {
    
    public static let componentWidth: CGFloat = 480
    
    public static let cornerRadius: CGFloat = 16
    
    public static let contentPadding: CGFloat = 32
    
    public static let artworkSize: CGFloat = 88
    
    public static let artworkCornerRadius: CGFloat = 8
    
    public static let secondaryButtonSize: CGFloat = 36
    
    public static let playButtonSize: CGFloat = 72
    
    public static let titleFont: UIFont = .systemFont(ofSize: 24, weight: .bold)
    
    public static let subtitleFont: UIFont = .systemFont(ofSize: 16, weight: .regular)
    
    public static let sliderTrackHeight: CGFloat = 4
    
    public static let sliderThumbDiameter: CGFloat = 12
    
    public static let backgroundColor = UIColor(red: 46.0/255.0, green: 50.0/255.0, blue: 64.0/255.0, alpha: 1.0)
    public static let selectedColor = UIColor(red: 0.0/255.0, green: 74.0/255.0, blue: 119.0/255.0, alpha: 1.0)
    public static let timelinePrimaryColor = UIColor(red:150.0/255.0, green: 152.0/255.0, blue: 159.0/255.0, alpha: 1.0)
    public static let timelineSecondaryColor = UIColor(red:88.0/255.0, green:91.0/255.0, blue:102.0/255.0, alpha: 1.0)
    
    public static let titleColor = UIColor.white
    public static let subtitleColor = UIColor.white.withAlphaComponent(0.5)
}
