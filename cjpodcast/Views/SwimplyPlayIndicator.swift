import SwiftUI

// FROM: https://github.com/docterd/SwimplyPlayIndicator

public struct SwimplyPlayIndicator: View {
    struct AnimationValue: Identifiable {
        let id: Int
        let maxValue: CGFloat
        let animation: Animation
    }

    @State private var animating: Bool = false
    private let minimalValue: CGFloat = 0.1
    public let lineColor: Color
    public let lineCount: Int

    private var animationValues: [AnimationValue] {
        let valueRange: ClosedRange<CGFloat> = (0.2 ... 1.0)
        let speedRange: ClosedRange<Double> = (0.7 ... 1.2)
        let animations: [Animation] = [.easeIn, .easeOut, .easeInOut, .linear]
        let values = (0 ..< lineCount).compactMap { (id) -> AnimationValue? in
            guard let animation = animations.randomElement() else { return nil }
            return AnimationValue(id: id, maxValue: CGFloat.random(in: valueRange),
                                  animation: animation.speed(Double.random(in: speedRange)))
        }
        return values
    }

    public init(lineCount: Int = 4, lineColor: Color = Color.black) {
        self.lineCount = lineCount
        self.lineColor = lineColor
    }

    public var body: some View {
        GeometryReader { reader in
            HStack(alignment: .center, spacing: 1) {
                ForEach(self.animationValues) { value in
                    LineView(maxValue: value.maxValue)
                        .stroke(self.lineColor, lineWidth: reader.size.width / 8)
                        .animation(value.animation.repeatForever())
                }
            }

        }
        .drawingGroup()
        .animation(Animation.linear)
    }
}

private extension SwimplyPlayIndicator {
    struct LineView: Shape {
        var maxValue: CGFloat

        var animatableData: CGFloat {
            get { maxValue }
            set { maxValue = newValue }
        }

        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: .init(x: rect.midX, y: rect.maxY))
            path.addLine(to: .init(x: rect.midX, y: rect.maxY - (maxValue * rect.height)))
            return path
        }
    }
}
