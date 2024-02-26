//
//  Audio.swift
//  ssc-vision
//
//  Created by Nikolai Madlener on 26.02.24.
//

import SwiftUI
import RealityKit

class Audio : Entity {
    let resource: AudioFileResource
    
    init(_ named: String) {
        resource = try! AudioFileResource.load(named: named)
    }
    func setupSpatialSound(pinnedTo: ModelEntity) {
        self.spatialAudio = SpatialAudioComponent()
        self.spatialAudio?.gain = -15             // decibels
        self.addChild(pinnedTo)
    }
    func playSpatialSound() {
        self.playAudio(resource)
    }
    func stopSpatialSound() {
        self.stopAllAudio()
    }
    @MainActor required init() {
        fatalError("Hasn't been implemented yet")
    }
}
