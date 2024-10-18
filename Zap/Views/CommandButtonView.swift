//
//  CommandButtonView.swift
//  Zap
//
//  Created by Zigao Wang on 10/18/24.
//

import SwiftUI
import AVFoundation

struct CommandButton: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var currentMode: InputMode = .center
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    
    private let hapticImpact = UIImpactFeedbackGenerator(style: .medium)
    private let buttonSize: CGFloat = 80
    private let outerCircleSize: CGFloat = 240
    private let maxDragDistance: CGFloat = 60
    
    enum InputMode: String, CaseIterable {
        case center = "mic"
        case text = "text.justify"
        case photo = "camera"
        case video = "video"
        case album = "photo.on.rectangle"
        
        var color: Color {
            switch self {
            case .center: return .blue
            case .text: return .green
            case .photo: return .orange
            case .video: return .red
            case .album: return .purple
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Full windmill-shaped colored sections
            ForEach(InputMode.allCases.filter { $0 != .center }, id: \.self) { mode in
                sectionView(for: mode)
            }
            
            // Section labels
            VStack {
                Text("Text").offset(y: -outerCircleSize/3)
                HStack {
                    Text("Photo").offset(x: -outerCircleSize/3)
                    Spacer()
                    Text("Video").offset(x: outerCircleSize/3)
                }
                Text("Album").offset(y: outerCircleSize/3)
            }
            .font(.caption)
            .foregroundColor(.white)
            
            // Center button with joystick movement
            Circle()
                .fill(viewModel.isRecording ? Color.red : Color.blue)
                .frame(width: buttonSize, height: buttonSize)
                .overlay(
                    Image(systemName: viewModel.isRecording ? "stop.circle" : "mic")
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                )
                .offset(dragOffset)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            updateJoystickPosition(value: value)
                        }
                        .onEnded { _ in
                            resetJoystickPosition()
                        }
                )
                .onTapGesture {
                    toggleRecording()
                }
            
            // Add a subtle glow effect
            Circle()
                .fill(currentMode.color)
                .frame(width: buttonSize * 1.2, height: buttonSize * 1.2)
                .blur(radius: 20)
                .opacity(isDragging ? 0.3 : 0)
                .offset(dragOffset)
                .animation(.easeInOut(duration: 0.2), value: isDragging)
        }
        .frame(width: outerCircleSize, height: outerCircleSize)
        .clipShape(Circle())
    }
    
    private func sectionView(for mode: InputMode) -> some View {
        let angle: Angle
        switch mode {
        case .album: angle = .degrees(45)
        case .video: angle = .degrees(-45)
        case .photo: angle = .degrees(135)
        case .text: angle = .degrees(225)
        default: angle = .degrees(0)
        }
        
        return Path { path in
            path.move(to: CGPoint(x: outerCircleSize / 2, y: outerCircleSize / 2))
            path.addLine(to: CGPoint(x: outerCircleSize, y: outerCircleSize / 2))
            path.addArc(center: CGPoint(x: outerCircleSize / 2, y: outerCircleSize / 2),
                        radius: outerCircleSize / 2,
                        startAngle: .degrees(0),
                        endAngle: .degrees(90),
                        clockwise: false)
            path.closeSubpath()
        }
        .fill(mode.color)
        .opacity(currentMode == mode ? 0.8 : 0.3)
        .rotationEffect(angle)
    }
    
    private func updateJoystickPosition(value: DragGesture.Value) {
        let dragVector = CGSize(
            width: min(max(value.translation.width, -maxDragDistance), maxDragDistance),
            height: min(max(value.translation.height, -maxDragDistance), maxDragDistance)
        )
        dragOffset = dragVector
        isDragging = true
        
        updateMode(for: CGPoint(x: outerCircleSize / 2 + dragVector.width,
                                y: outerCircleSize / 2 + dragVector.height))
    }
    
    private func resetJoystickPosition() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            dragOffset = .zero
            isDragging = false
        }
        executeAction()
    }
    
    private func updateMode(for location: CGPoint) {
        let center = CGPoint(x: outerCircleSize / 2, y: outerCircleSize / 2)
        let dx = location.x - center.x
        let dy = location.y - center.y
        
        if dx * dx + dy * dy < (buttonSize / 2) * (buttonSize / 2) {
            currentMode = .center
            return
        }
        
        let angle = atan2(dy, dx) * 180 / .pi
        let newMode: InputMode
        
        switch angle {
        case -45..<45:
            newMode = .video
        case 45..<135:
            newMode = .album
        case -135..<(-45):
            newMode = .text
        case -180..<(-135), 135...180:
            newMode = .photo
        default:
            newMode = .center
        }
        
        if newMode != currentMode {
            currentMode = newMode
            hapticImpact.impactOccurred(intensity: 0.7)
        }
    }
    
    private func executeAction() {
        switch currentMode {
        case .text:
            viewModel.showTextNoteInput()
        case .photo:
            viewModel.capturePhoto()
        case .video:
            viewModel.captureVideo()
        case .album:
            viewModel.showImagePicker()
        case .center:
            break
        }
        
        currentMode = .center
    }
    
    private func toggleRecording() {
        if viewModel.isRecording {
            viewModel.stopRecording()
        } else {
            viewModel.startRecording()
        }
        hapticImpact.impactOccurred()
    }
}
