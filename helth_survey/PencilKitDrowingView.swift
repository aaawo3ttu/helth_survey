import SwiftUI
import PencilKit

struct PencilKitDrawingView: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilKitDrawingView

        init(parent: PencilKitDrawingView) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        canvasView.drawing = drawing

        if let window = UIApplication.shared.windows.first {
            let toolPicker = PKToolPicker.shared(for: window)
            toolPicker?.setVisible(true, forFirstResponder: canvasView)
            toolPicker?.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing
    }
}
