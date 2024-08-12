import SwiftUI
import PencilKit

// DrawingView using PencilKit
struct DrawingView: UIViewRepresentable {
    @Binding var drawingImage: UIImage?

    // Creates the canvas view and configures it
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        canvasView.backgroundColor = UIColor.white
        canvasView.layer.cornerRadius = 10
        canvasView.layer.shadowRadius = 10
        canvasView.layer.shadowOpacity = 0.3
        
        // Configure the tool picker
        if let window = UIApplication.shared.windows.first(where: \.isKeyWindow) {
            let toolPicker = PKToolPicker.shared(for: window)
            toolPicker?.setVisible(true, forFirstResponder: canvasView)
            toolPicker?.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }
        
        // Set the initial drawing tool
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)

        return canvasView
    }

    // Updates the canvas view
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Any updates when the SwiftUI view is updated can be handled here
    }

    // Coordinator class to handle canvas view delegate methods
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingView

        init(_ parent: DrawingView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Convert the drawing to UIImage
            let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
            parent.drawingImage = image
        }
    }
}

