//
//  ContentView.swift
//  GratingSimulator
//
//  Created by Mark Barclay on 2/28/26.
//

import SwiftUI
import SpriteKit
import Combine

// configuration
let SHOW_NONESSENTIAL_SLIDERS = false
let SHOW_CONFIGURATION = false
let SHOW_GLOW_NODES = false
let INITIAL_ORDER: Int = 2
let INITIAL_ANGLE: Double = 5.0 // 28.25 // was 45

// MARK: - Content View
struct ContentView: View {
    @State private var angle: Double = INITIAL_ANGLE
    @State private var gratingPitch: Double = 10.0
    @State private var wavelength: Double = 532
    @State private var distance: Double = 1000
    @State private var maxOrder: Int = INITIAL_ORDER
    @StateObject private var sceneDelegate = SceneDelegate()

    var scene: GratingScene {
        let scene = sceneDelegate.scene
        scene.size = CGSize(width: 900, height: 900) // was 600
        scene.scaleMode = SKSceneScaleMode.aspectFit
        scene.backgroundColor = .black
        return scene
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title
            Text("Quad Grating Simulator")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding()

            // SpriteKit Scene
            SpriteView(scene: scene)
                .layoutPriority(9)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green, lineWidth: 2)
                )
                .padding(.horizontal)
                .onChange(of: angle) { newValue in
                    sceneDelegate.scene.angle = newValue
                }
                .onChange(of: gratingPitch) { newValue in
                    sceneDelegate.scene.gratingPitch = newValue
                }
                .onChange(of: wavelength) { newValue in
                    sceneDelegate.scene.wavelength = newValue
                }
                .onChange(of: distance) { newValue in
                    sceneDelegate.scene.distance = newValue
                }
                .onChange(of: maxOrder) { newValue in
                    sceneDelegate.scene.maxOrder = newValue
                }

            // Controls
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 20) {
                    if SHOW_CONFIGURATION {
                        // Grating Configuration Display
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Grating Configuration:")
                                .font(.subheadline)
                                .foregroundColor(.cyan)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("• G0: 0° (fixed)")
                                Text("• G1: 90° (fixed, ⟂ to G0)")
                                Text("• G2: \(Int(angle))° (adjustable)")
                                    .foregroundColor(.yellow)
                                Text("• G3: \(Int(angle) + 90)° (⟂ to G2)")
                                    .foregroundColor(.yellow)
                            }
                            .font(.caption)
                            .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(red: 0, green: 0.1, blue: 0.1))
                        .cornerRadius(8)
                    }

                    // Pair Rotation Angle
                    VStack(alignment: .leading) {
                        //let pairRotationAngle = Int(angle)
                        let pairRotationAngle = angle
                        let praStep = 0.25
                        let maxRotationAngle = 45 // was 90
                        Text("Pair Rotation Angle: \(pairRotationAngle)°")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        Slider(value: $angle, in: 0...45, step: praStep)
                            .accentColor(.green)
                        //Text("Angle between grating pairs (G0/G1 vs G2/G3)")
                        //    .font(.caption)
                        //    .foregroundColor(.gray)
                    }

                    // Max Order
                    VStack(alignment: .leading) {
                        Text("Max Diffraction Order: \(maxOrder)")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        Slider(value: Binding(
                            get: { Double(maxOrder) },
                            set: { maxOrder = Int($0) }
                        ), in: 1...4, step: 1)
                        .accentColor(.green)
                        //    Text("⚠️ Order 4 = \(Int(pow(Double(2 * 4 + 1), 4))) spots!")
                        //        .font(.caption)
                        //        .foregroundColor(.gray)
                    }

                    if SHOW_NONESSENTIAL_SLIDERS {
                        // Grating Pitch
                        VStack(alignment: .leading) {
                            Text("Grating Pitch: \(String(format: "%.1f", gratingPitch)) μm")
                                .font(.subheadline)
                                .foregroundColor(.green)
                            Slider(value: $gratingPitch, in: 5...50, step: 1)
                                .accentColor(.green)
                            Text("Spacing between grating lines")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        // Wavelength
                        VStack(alignment: .leading) {
                            Text("Wavelength: \(Int(wavelength)) nm")
                                .font(.subheadline)
                                .foregroundColor(.green)
                            Slider(value: $wavelength, in: 450...650, step: 1)
                                .accentColor(.green)
                            Text("Green laser: ~532nm")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        // Screen Distance
                        VStack(alignment: .leading) {
                            Text("Screen Distance: \(Int(distance)) mm")
                                .font(.subheadline)
                                .foregroundColor(.green)
                            Slider(value: $distance, in: 500...3000, step: 100)
                                .accentColor(.green)
                            Text("Distance to projection screen")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(red: 0.05, green: 0.05, blue: 0.05))
            }
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Scene Delegate
class SceneDelegate: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    let scene: GratingScene

    init() {
        self.scene = GratingScene()
    }
}

// MARK: - SpriteKit Scene
class GratingScene: SKScene {
    var angle: Double = INITIAL_ANGLE { didSet { updatePattern() } }
    var gratingPitch: Double = 5.0 { didSet { updatePattern() } }
    var wavelength: Double = 532 { didSet { updatePattern() } }
    var distance: Double = 1000 { didSet { updatePattern() } }
    var maxOrder: Int = INITIAL_ORDER { didSet { updatePattern() } }

    private var spotNodes: [SKNode] = []

    override func didMove(to view: SKView) {
        updatePattern()
    }

    private func updatePattern() {
        // Remove existing spots
        spotNodes.forEach { $0.removeFromParent() }
        spotNodes.removeAll()

        // Physics parameters
        let lambda = wavelength * 1e-9 // wavelength in meters
        let d = gratingPitch * 1e-6 // grating pitch in micrometers
        let L = distance * 1e-3 // screen distance in meters

        // Calculate scale
        let maxSinTheta = Double(maxOrder) * lambda / d
        guard maxSinTheta <= 1.0 else { return }

        // For order 1, make more room around the dot pattern
        let scaleMultiplier = switch maxOrder {
        case 1: 0.5
        case 2: 1.0
        case 3: 1.5
        case 4: 2.0
        default: 1.0
        }

        let maxTheta = asin(maxSinTheta)
        let scale = size.width / (2 * L * tan(maxTheta) * 1.5) * scaleMultiplier

        let centerX = size.width / 2
        let centerY = size.height / 2

        // Grating angles
        let angleRad = angle * .pi / 180
        let fudge = 0.000

        let gratingAngles = [
            0.0 + fudge,
            .pi / 2,
            angleRad + fudge,
            angleRad + .pi / 2,
        ]

        // Store spots
        struct Spot {
            let x: CGFloat
            let y: CGFloat
            let intensity: Double
        }
        var spots: [Spot] = []

        // Generate all diffraction orders
        for m0 in -maxOrder...maxOrder {
            let sinTheta0 = Double(m0) * lambda / d
            guard abs(sinTheta0) <= 1 else { continue }

            for m1 in -maxOrder...maxOrder {
                let sinTheta1 = Double(m1) * lambda / d
                guard abs(sinTheta1) <= 1 else { continue }

                for m2 in -maxOrder...maxOrder {
                    let sinTheta2 = Double(m2) * lambda / d
                    guard abs(sinTheta2) <= 1 else { continue }

                    for m3 in -maxOrder...maxOrder {
                        let sinTheta3 = Double(m3) * lambda / d
                        guard abs(sinTheta3) <= 1 else { continue }

                        let orders = [m0, m1, m2, m3]
                        var x_total = 0.0
                        var y_total = 0.0

                        for i in 0..<4 {
                            let theta = asin(Double(orders[i]) * lambda / d)
                            let displacement = L * tan(theta)

                            x_total += displacement * cos(gratingAngles[i])
                            y_total += displacement * sin(gratingAngles[i])
                        }

                        let diminishFactor = -0.05 // was -0.15 -0.08

                        // Intensity
                        let intensity = exp(diminishFactor * Double(m0*m0 + m1*m1 + m2*m2 + m3*m3))
                        //let intensity = 2.0 * exp(-0.15 * Double(m0*m0 + m1*m1 + m2*m2 + m3*m3))

                        let px = centerX + CGFloat(x_total * scale)
                        let py = centerY + CGFloat(y_total * scale)

                        spots.append(Spot(x: px, y: py, intensity: intensity))
                    }
                }
            }
        }

        // Normalize and draw spots
        let maxIntensity = spots.map { $0.intensity }.max() ?? 1.0

        for spot in spots {
            let normalizedIntensity = spot.intensity / maxIntensity
            let widthFactor: CGFloat = 15.0      // was 15.0
            let circleRadius: CGFloat = 1.5   // was 2.5

            if SHOW_GLOW_NODES {
                let glowRadius_base: CGFloat = 2.0  // was 10.0
                let glowRadius = CGFloat(glowRadius_base + normalizedIntensity * 20)

                // Create glow node
                let glowNode = SKShapeNode(circleOfRadius: glowRadius)
                glowNode.position = CGPoint(x: spot.x, y: spot.y)
#if os(macOS)
                // macOS-specific code
                glowNode.fillColor = NSColor(
                    red: 0.7,
                    green: 1.0,
                    blue: 0.7,
                    alpha: CGFloat(normalizedIntensity)
                )
#else
                // iOS-specific code
                glowNode.fillColor = UIColor(
                    red: 0.7,
                    green: 1.0,
                    blue: 0.7,
                    alpha: CGFloat(normalizedIntensity)
                )
#endif
                glowNode.strokeColor = .clear
                glowNode.glowWidth = CGFloat(normalizedIntensity * widthFactor)

                addChild(glowNode)
                spotNodes.append(glowNode)
            }

            // Create bright core
            if normalizedIntensity > 0.2 {
                let coreNode = SKShapeNode(circleOfRadius: circleRadius)
                coreNode.position = CGPoint(x: spot.x, y: spot.y)
#if os(macOS)
                // macOS-specific code
                coreNode.fillColor = NSColor(
                    red: 0.7,
                    green: 1.0,
                    blue: 0.7,
                    alpha: CGFloat(normalizedIntensity)
                )
#else
                // iOS-specific code
                coreNode.fillColor = UIColor(
                    red: 0.7,
                    green: 1.0,
                    blue: 0.7,
                    alpha: CGFloat(normalizedIntensity)
                )
#endif
                coreNode.strokeColor = .clear

                addChild(coreNode)
                spotNodes.append(coreNode)
            }
        }

        // Add info label
        let infoLabel = SKLabelNode(fontNamed: "Courier")
        infoLabel.fontSize = 12
        infoLabel.fontColor = .green
        infoLabel.position = CGPoint(x: 10, y: size.height - 20)
        infoLabel.horizontalAlignmentMode = .left
        infoLabel.text = "Spots: \(spots.count) | Angle: \(Int(angle))°"
        addChild(infoLabel)
        spotNodes.append(infoLabel)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
