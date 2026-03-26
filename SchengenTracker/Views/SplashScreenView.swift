import SwiftUI

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.38
        var path = Path()
        for i in 0..<10 {
            let angle = Angle(degrees: Double(i) * 36 - 90)
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle.radians)) * radius,
                y: center.y + CGFloat(sin(angle.radians)) * radius
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct SplashScreenView: View {
    @State private var phase = 0
    @State private var dismissSplash = false

    let onFinished: () -> Void

    private let euYellow = Color(red: 1.0, green: 0.8, blue: 0.0)
    private let euBlue = Color(red: 0.145, green: 0.388, blue: 0.922)

    var body: some View {
        ZStack {
            euBlue

            VStack(spacing: 24) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(euYellow, lineWidth: 3.5)
                    .frame(width: 280, height: 280)
                    .scaleEffect(phase >= 1 ? 1 : 0.3)
                    .opacity(phase >= 1 ? 1 : 0)

                // Inner ring
                Circle()
                    .stroke(euYellow, lineWidth: 2.5)
                    .frame(width: 203, height: 203)
                    .scaleEffect(phase >= 1 ? 1 : 0.3)
                    .opacity(phase >= 1 ? 1 : 0)

                // 12 EU stars
                ForEach(0..<12, id: \.self) { i in
                    let angle = Angle(degrees: Double(i) * 30 - 90)
                    let radius: CGFloat = 120
                    StarShape()
                        .fill(euYellow)
                        .frame(width: 22, height: 22)
                        .offset(
                            x: CGFloat(cos(angle.radians)) * radius,
                            y: CGFloat(sin(angle.radians)) * radius
                        )
                        .scaleEffect(phase >= 2 ? 1 : 0)
                        .opacity(phase >= 2 ? 1 : 0)
                }
                .rotationEffect(phase >= 2 ? .zero : .degrees(-30))

                // Main text "90"
                Text("90")
                    .font(.system(size: 88, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .offset(y: -12)
                    .scaleEffect(phase >= 3 ? 1 : 0.5)
                    .opacity(phase >= 3 ? 1 : 0)

                // Subtext "/180"
                Text("/180")
                    .font(.system(size: 36, weight: .regular, design: .default))
                    .foregroundColor(.white.opacity(0.85))
                    .offset(y: 38)
                    .scaleEffect(phase >= 3 ? 1 : 0.5)
                    .opacity(phase >= 3 ? 1 : 0)
            }

            // App name
            Text("Schengen Tracker")
                .font(.system(size: 28, weight: .medium, design: .default))
                .foregroundColor(.white)
                .opacity(phase >= 3 ? 1 : 0)
                .offset(y: phase >= 3 ? 0 : 10)
            }
        }
        .ignoresSafeArea()
        .opacity(dismissSplash ? 0 : 1)
        .scaleEffect(dismissSplash ? 1.1 : 1)
        .onAppear {
            // Phase 1: Rings expand (immediate)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                phase = 1
            }

            // Phase 2: Stars appear + rotate
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    phase = 2
                }
            }

            // Phase 3: Text appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    phase = 3
                }
            }

            // Hold for a beat, then dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.easeIn(duration: 0.35)) {
                    dismissSplash = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onFinished()
                }
            }
        }
    }
}
