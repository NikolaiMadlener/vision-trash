//
//  GameView.swift
//  ssc-vision
//
//  Created by Nikolai Madlener on 21.02.24.
//

import SwiftUI
import RealityKit

struct GameStatsView: View {
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    @State private var timeRemaining = 3
    
    @Binding var points: Int
    @Binding var gameover: Bool
    @Binding var gameOverReason: String
    
    var body: some View {
        ZStack {
            VStack {
                if gameover {
                    Text("Game over!").font(.title)
                    Text(gameOverReason)
                        .multilineTextAlignment(.center)
                        .padding(8)
                }
                if timeRemaining == 0 {
                    Text("Points:").font(.title)
                    Text("\(points)").font(.extraLargeTitle)
                }
                if gameover {
                    Button("Back to Start") {
                        gameover = false
                        points = 0
                        openWindow(id: "Start")
                    }
                }
            }
            if timeRemaining > 0 {
                VStack {
                    Text("Get ready!").font(.title)
                    Text("\(timeRemaining)")
                        .font(.extraLargeTitle)
                        .fontDesign(.rounded)
                        .foregroundStyle(.red)
                }
            }
        }
        .onAppear {
            dismissWindow(id: "Start")
            Task {
                await openImmersiveSpace(id: "Game")
            }
            startCountdown()
        }
    }
    private func startCountdown() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    startCountdown()
                }
            }
        }
}

#Preview {
    GameStatsView(points: .constant(0), gameover: .constant(true), gameOverReason: .constant("Trash touched the floor!"))
}
