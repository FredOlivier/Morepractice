
//
//  Score.swift
//  Morepractice
//
//  Created by Fred Olivier on 17/09/2024.
//
import Foundation
import SwiftUI
import UIKit

struct Score: Identifiable, Codable {
    var id: UUID  // Removed the default value
    var slider1: Double
    var slider2: Double
    var image1: String
    var image2: String
    var image1URL: String
    var image2URL: String
    var relationalScore: Double
    var date: Date  // Assuming date exists
    
    
}
