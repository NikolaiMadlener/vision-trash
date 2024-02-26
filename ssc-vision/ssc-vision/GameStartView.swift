//
//  ContentView.swift
//  ssc-vision
//
//  Created by Nikolai Madlener on 16.02.24.
//

import SwiftUI
import RealityKit

struct GameStartView: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    @AppStorage("HighScore") private var highScore = 0
    
    var body: some View {
        VStack {
            Text("Trash it!")
                .font(.extraLargeTitle)
                .padding(4)
            Text(
                """
                 Help us save the planet and toss all the trash in the right bins before it touches to floor!
                """
            )
            .padding()
            .multilineTextAlignment(.center)
            .font(.headline)

            HStack {
                trashBinCell(modelName: "TrashBinOrganic", title: "🟢 Green Container", description: "Food waste, yard waste, green waste, other organic materials.", imageName: "organicBin")
        
                trashBinCell(modelName: "TrashBinRecycle", title: "🔵 Blue Container", description: "Recyclables like bottles, cans, and plastic, and organic waste like paper and cardboard.", imageName: "recycleBin")
                
                trashBinCell(modelName: "TrashBinSolid", title: "⚫️ Gray Container", description: "Limited to waste that is not organic or recyclable.", imageName: "solidBin")
                
            }.frame(height: 350).padding()
            Spacer()
            Button("Play Now") {
                openWindow(id: "GameStats")
                
//                Task {
//                    await openImmersiveSpace(id: "Game")
//                }
                
            }.controlSize(.extraLarge)
            Spacer()
            Text("Personal High Score: " + "\(highScore)" + " Points").padding(4)
        }
        .onAppear {
            dismissWindow(id: "GameStats")
        }
        .padding()
    }
    
    func trashBinCell(modelName: String, title: String, description: String, imageName: String) -> some View {
        VStack {
            VStack {
                Image(imageName)
                    .resizable()
                    .cornerRadius(16)
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(0.8)
                    .frame(width: 720, height: 210)
            }.background(.white)
            
            Spacer()
            VStack {
                Text(title).font(.headline).padding()
                Spacer()
                Text(description).multilineTextAlignment(.center).font(.body).padding(.horizontal)
                Spacer()
            }.frame(height: 140)
        
        }.frame(minWidth: 0, maxWidth: .infinity).padding(.bottom).background().cornerRadius(16)
    }
}

#Preview() {
    GameStartView()
}
