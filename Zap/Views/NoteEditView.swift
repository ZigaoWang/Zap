//
//  NoteEditView.swift
//  Zap
//
//  Created by Zigao Wang on 10/2/24.
//

import SwiftUI

struct TextNoteEditView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @State private var editedText: String
    let note: NoteItem
    @Environment(\.presentationMode) var presentationMode

    init(note: NoteItem) {
        self.note = note
        if case .text(let content) = note.type {
            _editedText = State(initialValue: content)
        } else {
            _editedText = State(initialValue: "")
        }
    }

    var body: some View {
        NavigationView {
            TextEditor(text: $editedText)
                .padding()
                .navigationBarTitle("Edit Note", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Save") {
                        viewModel.updateTextNote(note, with: editedText)
                        presentationMode.wrappedValue.dismiss()
                    }
                )
        }
    }
}

struct AudioNoteEditView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @State private var editedTranscription: String
    let note: NoteItem
    @Environment(\.presentationMode) var presentationMode

    init(note: NoteItem) {
        self.note = note
        _editedTranscription = State(initialValue: note.transcription ?? "")
    }

    var body: some View {
        NavigationView {
            TextEditor(text: $editedTranscription)
                .padding()
                .navigationBarTitle("Edit Transcription", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Save") {
                        viewModel.updateAudioNoteTranscription(note, with: editedTranscription)
                        presentationMode.wrappedValue.dismiss()
                    }
                )
        }
    }
}

struct PhotoNoteEditView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @State private var currentDrawing: Drawing = Drawing()
    @State private var drawings: [Drawing] = []
    @State private var color: Color = .red
    @State private var lineWidth: CGFloat = 3
    @State private var image: UIImage?
    @State private var scale: CGFloat = 1.0
    let note: NoteItem
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    if let image = image {
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .overlay(
                                    Canvas { context, size in
                                        let imageSize = image.size
                                        let scaleFactor = min(size.width / imageSize.width, size.height / imageSize.height)
                                        let scaledSize = CGSize(width: imageSize.width * scaleFactor, height: imageSize.height * scaleFactor)
                                        let offset = CGPoint(x: (size.width - scaledSize.width) / 2, y: (size.height - scaledSize.height) / 2)
                                        
                                        context.translateBy(x: offset.x, y: offset.y)
                                        context.scaleBy(x: scaleFactor, y: scaleFactor)
                                        
                                        for drawing in drawings {
                                            var path = Path()
                                            path.addLines(drawing.points)
                                            context.stroke(path, with: .color(drawing.color), lineWidth: drawing.lineWidth)
                                        }
                                        var path = Path()
                                        path.addLines(currentDrawing.points)
                                        context.stroke(path, with: .color(currentDrawing.color), lineWidth: currentDrawing.lineWidth)
                                    }
                                )
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let imageSize = image.size
                                    let viewSize = geometry.size
                                    let scaleFactor = min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
                                    let scaledSize = CGSize(width: imageSize.width * scaleFactor, height: imageSize.height * scaleFactor)
                                    let offset = CGPoint(x: (viewSize.width - scaledSize.width) / 2, y: (viewSize.height - scaledSize.height) / 2)
                                    
                                    let newPoint = CGPoint(
                                        x: (value.location.x - offset.x) / scaleFactor,
                                        y: (value.location.y - offset.y) / scaleFactor
                                    )
                                    currentDrawing.points.append(newPoint)
                                }
                                .onEnded { _ in
                                    drawings.append(currentDrawing)
                                    currentDrawing = Drawing(color: color, lineWidth: lineWidth)
                                }
                        )
                    } else {
                        Text("Image not found")
                    }
                    
                    HStack {
                        ColorPicker("Color", selection: $color)
                        Slider(value: $lineWidth, in: 1...10) { Text("Line Width") }
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Edit Photo", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveAnnotatedImage()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear(perform: loadImage)
    }
    
    private func loadImage() {
        if case .photo(let fileName) = note.type {
            image = UIImage(contentsOfFile: viewModel.getFilePath(fileName))
        }
    }
    
    private func saveAnnotatedImage() {
        guard let image = image, case .photo(let fileName) = note.type else { return }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(at: .zero)
        
        for drawing in drawings {
            let path = UIBezierPath()
            if let firstPoint = drawing.points.first {
                path.move(to: firstPoint)
                for point in drawing.points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            
            UIColor(drawing.color).setStroke()
            path.lineWidth = drawing.lineWidth
            path.stroke()
        }
        
        if let annotatedImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            
            if let data = annotatedImage.jpegData(compressionQuality: 0.8) {
                let url = viewModel.getDocumentsDirectory().appendingPathComponent(fileName)
                do {
                    try data.write(to: url)
                    viewModel.updatePhotoNote(note, fileName: fileName)
                } catch {
                    print("Failed to save annotated image: \(error)")
                }
            }
        }
    }
}

struct Drawing: Identifiable {
    let id = UUID()
    var points: [CGPoint] = []
    var color: Color = .red
    var lineWidth: CGFloat = 3
}
