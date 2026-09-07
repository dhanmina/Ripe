import SwiftUI

/// The one deliberate departure from Ripe's native-only icon system: a
/// custom-drawn tomato whose color ripens from unripe green to tomato red
/// as a focus session progresses. `ripeness` is driven by real elapsed
/// time (0 = just started, 1 = complete) — it's a progress indicator with
/// personality, not decoration or fabricated gamification.
struct TomatoIcon: View {
    var ripeness: Double

    var body: some View {
        ZStack {
            TomatoBody()
                .fill(bodyColor)
                .overlay(TomatoBody().stroke(.black.opacity(0.15), lineWidth: 0.75))
            TomatoCalyx()
                .fill(Color(red: 0.30, green: 0.55, blue: 0.25))
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var bodyColor: Color {
        let clamped = min(max(ripeness, 0), 1)
        let unripe = (r: 0.58, g: 0.64, b: 0.30)
        let ripe = (r: 0.85, g: 0.22, b: 0.18)
        return Color(
            red: unripe.r + (ripe.r - unripe.r) * clamped,
            green: unripe.g + (ripe.g - unripe.g) * clamped,
            blue: unripe.b + (ripe.b - unripe.b) * clamped
        )
    }
}

private struct TomatoBody: Shape {
    func path(in rect: CGRect) -> Path {
        let body = rect.insetBy(dx: rect.width * 0.06, dy: rect.height * 0.10)
        return Path(ellipseIn: body)
    }
}

private struct TomatoCalyx: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width * 0.34
        let height = rect.height * 0.16
        let notch = CGRect(
            x: rect.midX - width / 2,
            y: rect.minY,
            width: width,
            height: height
        )
        return Path(roundedRect: notch, cornerRadius: height / 2)
    }
}

#Preview {
    HStack(spacing: 12) {
        TomatoIcon(ripeness: 0).frame(width: 24, height: 24)
        TomatoIcon(ripeness: 0.5).frame(width: 24, height: 24)
        TomatoIcon(ripeness: 1).frame(width: 24, height: 24)
    }
    .padding()
}
