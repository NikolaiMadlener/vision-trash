//
//  DraggableTrash.swift
//  ssc-vision
//
//  Created by Nikolai Madlener on 21.02.24.
//


import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveGameView: View {
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @AppStorage("HighScore") private var highScore = 0
    @State private var subs: [EventSubscription] = []
    @State var newObject = ModelEntity()
    @State var damping_factor = 1_000_000_000
    
    @Binding var points: Int
    @Binding var gameover: Bool
    @Binding var gameOverReason: String
    
    var trash: [TrashModel] = TrashModel.self.getData()
    
    var body: some View {
        let nonTrashGroup = CollisionGroup(rawValue: 1 << 0)
        let nonTrashMask = CollisionGroup.all.subtracting(nonTrashGroup)
        let nonTrashFilter = CollisionFilter(group: nonTrashGroup,
                                             mask: nonTrashMask)
        
        // Trash Collisiongroup so trash doesnt collide with each other but only floor and bins
        let trashGroup = CollisionGroup(rawValue: 1 << 1)
        let trashMask = CollisionGroup.all.subtracting(trashGroup)
        let trashFilter = CollisionFilter(group: trashGroup,
                                          mask: trashMask)
        
        RealityView { content in
            /// Floor
            let floor = ModelEntity(mesh: .generatePlane(width: 50, depth: 50), materials: [OcclusionMaterial()])
            
            floor.generateCollisionShapes(recursive: false)
            floor.components[PhysicsBodyComponent.self] = .init(
                massProperties: .default,
                mode: .static
            )
            
            floor.position = SIMD3<Float>(0, 0.01, 0)
            floor.name = "floor"
            floor.collision?.filter = nonTrashFilter
            content.add(floor)
            
            
            let floorCollisionEvent = content.subscribe(to: CollisionEvents.Began.self, on: floor) { _ in
                gameOverSound(modelEntity: floor)
                gameOverReason = "Trash touched the floor!"
                gameOver()
            }
            
            Task {
                subs.append(floorCollisionEvent)
            }
            
            /// Organic Trash Bin
            if let organicTrashBin = try? await ModelEntity(named: "TrashBinOrganic") {
                organicTrashBin.position = SIMD3<Float>(-1, 0.1, -2)
                organicTrashBin.scale = SIMD3<Float>(repeating: 0.2)
                organicTrashBin.components.set(CollisionComponent(shapes: [ShapeResource.generateBox(width: 0.5, height: 1.5, depth: 0.45)]))
                organicTrashBin.collision?.filter = nonTrashFilter
                organicTrashBin.name = "trashOrganic"
                
                let organicTrashBinCollisionEvent = content.subscribe(to: CollisionEvents.Began.self, on: organicTrashBin) { event in
                    
                    let trash = event.entityB
                    
                    if trash.name == "organic" {
                        successSound(modelEntity: organicTrashBin)
                        points += 1
                        trash.removeFromParent()
                    } else {
                        gameOverSound(modelEntity: organicTrashBin)
                        gameOverReason = "🚨 You tossed " + trash.name + " trash into the green container."
                        gameOver()
                    }
                }
                Task {
                    subs.append(organicTrashBinCollisionEvent)
                }
                content.add(organicTrashBin)
            }
            
            /// Paper Trash Bin
            if let recycleTrashBin = try? await ModelEntity(named: "TrashBinRecycle") {
                recycleTrashBin.position = SIMD3<Float>(0, 0.1, -2)
                recycleTrashBin.scale = SIMD3<Float>(repeating: 0.2)
                recycleTrashBin.components.set(CollisionComponent(shapes: [ShapeResource.generateBox(width: 0.5, height: 1.5, depth: 0.45)]))
                recycleTrashBin.collision?.filter = nonTrashFilter
                recycleTrashBin.name = "trashPaper"
                
                let recycleTrashBinCollisionEvent = content.subscribe(to: CollisionEvents.Began.self, on: recycleTrashBin) { event in
                    
                    let trash = event.entityB
                    
                    if trash.name == "recycle" {
                        successSound(modelEntity: recycleTrashBin)
                        points += 1
                        trash.removeFromParent()
                    } else {
                        gameOverSound(modelEntity: recycleTrashBin)
                        gameOverReason = "🚨 You tossed " + trash.name + " trash into the blue container."
                        gameOver()
                    }
                }
                Task {
                    subs.append(recycleTrashBinCollisionEvent)
                }
                content.add(recycleTrashBin)
            }
            
            /// Solid Trash Bin
            if let solidTrashBin = try? await ModelEntity(named: "TrashBinSolid") {
                solidTrashBin.position = SIMD3<Float>(1, 0.1, -2)
                solidTrashBin.scale = SIMD3<Float>(repeating: 0.2)
                solidTrashBin.components.set(CollisionComponent(shapes: [ShapeResource.generateBox(width: 0.5, height: 1.5, depth: 0.45)]))
                solidTrashBin.collision?.filter = nonTrashFilter
                solidTrashBin.name = "trashSolid"
                
                let solidTrashBinCollisionEvent = content.subscribe(to: CollisionEvents.Began.self, on: solidTrashBin) { event in
                    
                    let trash = event.entityB
                    
                    if trash.name == "solid" {
                        successSound(modelEntity: solidTrashBin)
                        points += 1
                        trash.removeFromParent()
                    } else {
                        gameOverSound(modelEntity: solidTrashBin)
                        gameOverReason = "🚨 You tossed " + trash.name + " trash into the gray container."
                        gameOver()
                    }
                }
                Task {
                    subs.append(solidTrashBinCollisionEvent)
                }
                content.add(solidTrashBin)
            }
            
            /// Generate new trash periodically
            generateNewTrash(filter: trashFilter)
            
        } update: { content in
            content.add(newObject)
        }
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .onChanged{ value in
                if value.entity.name != "trashPaper" && value.entity.name != "trashOrganic" && value.entity.name != "trashSolid" {
                    // Modify the collision filter so the entity won't collide with the nontrash group while being dragged. It also should not collide with other entities in trash group
                    let dragTrashFilter = CollisionFilter(group: trashGroup, mask: nonTrashMask.subtracting(trashGroup))
                    value.entity.components[CollisionComponent.self]?.filter = dragTrashFilter
                    
                    // adjust physics to enable smooth drag
                    value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
                    value.entity.components[PhysicsBodyComponent.self]?.linearDamping = 1
                    var newValue = value.convert(value.location3D, from: .local, to: value.entity.parent!)
                    
                    
                    // only allow drags across x and y axis
                    newValue.z = -2
                    value.entity.position = newValue
                }
            }.onEnded { value in
                // when drag ended, objects should fall again
                if value.entity.name != "trashPaper" && value.entity.name != "trashOrganic" {
                    value.entity.components[CollisionComponent.self]?.filter = trashFilter
                    value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
                    value.entity.components[PhysicsBodyComponent.self]?.linearDamping = 35
                }
            }
        )
        .hoverEffect()
    }

    func gameOver() {
        gameover = true
        if points > UserDefaults.standard.integer(forKey: "HighScore") {
            highScore = points
        }
        Task {
            await dismissImmersiveSpace()
        }
    }
    
    func successSound(modelEntity: ModelEntity) {
        Task {
            if let successSound = try? await AudioFileResource.load(named: "success.mp3") {
                await modelEntity.playAudio(successSound)
            }
        }
    }
    
    func gameOverSound(modelEntity: ModelEntity) {
        Task {
            if let gameOverSound = try? await AudioFileResource.load(named: "gameover.mp3") {
                await modelEntity.playAudio(gameOverSound)
            }
        }
    }
    
    /// Periodically generates new random trash
    @MainActor
    func generateNewTrash(filter: CollisionFilter) {
        Task {
            try await Task.sleep(nanoseconds: UInt64(3_000_000_000))
            while !gameover {
                let trashObject = trash.randomElement()!
                if let modelEntity = try? await ModelEntity(named: trashObject.entityName) {
                    let x = Float.random(in: -1.5...1.5)
                    let y = Float.random(in: 2.1...2.3)
                    
                    modelEntity.position = SIMD3<Float>(x, y, -2)
                    modelEntity.scale = SIMD3<Float>(repeating: 1.5)
                    modelEntity.name = trashObject.type.rawValue
                    
                    modelEntity.components.set(InputTargetComponent())
                    modelEntity.components.set(CollisionComponent(shapes: [ShapeResource.generateSphere(radius: 0.2)], filter: filter))
                    modelEntity.components[PhysicsBodyComponent.self] = .init(
                        massProperties: .init(mass: 0.1),
                        mode: .dynamic
                    )
                    // slow down speed of free fall
                    modelEntity.components[PhysicsBodyComponent.self]?.linearDamping = 35
                    
                    // add some rotation to the objects for easier identification
                    modelEntity.physicsMotion = .init()
                    modelEntity.physicsMotion?.angularVelocity.y = -.pi/2
                    modelEntity.physicsMotion?.angularVelocity.z = -.pi/12
                    
                    newObject = modelEntity
                    damping_factor /= 2
                    
                    // wait before spawning new trash
                    try await Task.sleep(nanoseconds: UInt64(500_000_000 + damping_factor))
                }
            }
        }
    }
}


#Preview {
    ImmersiveGameView(points: .constant(0), gameover: .constant(false), gameOverReason: .constant(""))
        .previewLayout(.sizeThatFits)
    
}
