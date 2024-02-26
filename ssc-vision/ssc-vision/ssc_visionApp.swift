//
//  ssc_visionApp.swift
//  ssc-vision
//
//  Created by Nikolai Madlener on 16.02.24.
//

import SwiftUI

@main
struct ssc_visionApp: App {
    @State var points = 0
    @State var gameover = false
    @State var gameOverReason = ""
    
    var body: some Scene {
        WindowGroup(id: "Start") {
            GameStartView()
        }
        
        WindowGroup(id: "GameStats") {
            GameStatsView(points: $points, gameover: $gameover, gameOverReason: $gameOverReason)
        }.defaultSize(CGSize(width: 300, height: 300))
        
        ImmersiveSpace(id: "Game") {
            ImmersiveGameView(points: $points, gameover: $gameover, gameOverReason: $gameOverReason)
            
        }
    }
}
