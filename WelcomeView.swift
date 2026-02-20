import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    Button {
                        authVM.isLoggedIn = true
                    } label: {
                        LogoLockup()
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 48)

                    HeroIllustration()

                    VStack(spacing: 6) {
                        Text("Split & Settle")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.black)

                        Text("Split expenses with friends.\nSettle up instantly.")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 32)

                    VStack(spacing: 14) {
                        Button {
                            Task { await authVM.signInWithGoogle() }
                        } label: {
                            AuthButtonContent(
                                label: "Continue with Google",
                                icon: "google",
                                style: .light
                            )
                        }

                        Button {
                            Task { await authVM.signInWithApple() }
                        } label: {
                            AuthButtonContent(
                                label: "Continue with Apple",
                                icon: "apple.logo",
                                style: .dark
                            )
                        }

                        NavigationLink {
                            DashboardView()
                        } label: {
                            AuthButtonContent(
                                label: "Continue As Guest",
                                icon: "person.crop.circle.badge.questionmark",
                                style: .light
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    if let error = authVM.errorMessage {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    HStack(spacing: 6) {
                        Text("Already have an account?")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        NavigationLink("Log in") {
                            LoginView()
                        }
                        .font(.system(size: 14, weight: .semibold))
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Logo

struct LogoLockup: View {
    var body: some View {
        HStack(spacing: 12) {
            SettleLogo()
                .frame(width: 50, height: 50)
            Text("settle")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.black)
        }
    }
}

struct SettleLogo: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black)
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white, lineWidth: 2)
                .padding(1)

            // Dollar sign with arrows
            ZStack {
                Text("$")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Diagonal arrow line
                ArrowLine()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .frame(width: 34, height: 34)
            }
        }
    }
}

struct ArrowLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let start = CGPoint(x: rect.minX + 4, y: rect.maxY - 4)
        let end = CGPoint(x: rect.maxX - 4, y: rect.minY + 4)

        // Main diagonal line
        path.move(to: start)
        path.addLine(to: end)

        // Top-right arrowhead
        path.move(to: CGPoint(x: end.x - 7, y: end.y))
        path.addLine(to: end)
        path.addLine(to: CGPoint(x: end.x, y: end.y + 7))

        // Bottom-left arrowhead
        path.move(to: CGPoint(x: start.x + 7, y: start.y))
        path.addLine(to: start)
        path.addLine(to: CGPoint(x: start.x, y: start.y - 7))

        return path
    }
}

// MARK: - Hero

private struct HeroIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 8)
                .frame(height: 200)
            VStack(spacing: 12) {
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .font(.system(size: 54, weight: .light))
                    .foregroundStyle(.black.opacity(0.8))
                Image(systemName: "person.2.fill")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(.black.opacity(0.6))
                Text("Track balances. Settle debts. Stay even.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 28)
    }
}

// MARK: - Auth Buttons

enum AuthButtonStyle {
    case light
    case dark
}

struct AuthButtonContent: View {
    var label: String
    var icon: String
    var style: AuthButtonStyle

    var body: some View {
        HStack {
            if icon == "google" {
                GoogleGlyph()
            } else {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
            }
            Spacer()
            Text(label)
                .font(.system(size: 16, weight: .semibold))
            Spacer()
        }
        .padding()
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(style == .dark ? Color.black : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(style == .dark ? Color.black : Color.black.opacity(0.08), lineWidth: 1)
                )
        )
        .foregroundColor(style == .dark ? .white : .black)
    }
}

struct GoogleGlyph: View {
    var body: some View {
        Canvas(rendersAsynchronously: false) { context, size in
            let s = min(size.width, size.height)
            let cx = size.width / 2
            let cy = size.height / 2
            let center = CGPoint(x: cx, y: cy)
            let R = s / 2
            let r = R * 0.6
            let stroke = R - r

            let red    = Color(red: 0.917, green: 0.263, blue: 0.208)
            let yellow = Color(red: 0.984, green: 0.737, blue: 0.020)
            let green  = Color(red: 0.204, green: 0.659, blue: 0.325)
            let blue   = Color(red: 0.263, green: 0.522, blue: 0.957)

            func ring(_ s1: Double, _ e1: Double, _ c: Color) {
                var p = Path()
                p.addArc(center: center, radius: R, startAngle: .degrees(s1), endAngle: .degrees(e1), clockwise: false)
                p.addArc(center: center, radius: r, startAngle: .degrees(e1), endAngle: .degrees(s1), clockwise: true)
                p.closeSubpath()
                context.fill(p, with: .color(c))
            }

            // Ring segments — matches official Google "G" proportions
            ring(180, 270, blue)     // left → top
            ring(-90, -2,  red)      // top → right (gap at ~0°)
            ring(-2,  90,  yellow)   // right → bottom
            ring(90,  180, green)    // bottom → left

            // Horizontal bar (the serif of the G)
            let barY = cy - stroke / 2
            let barRect = CGRect(x: cx, y: barY, width: R + 0.5, height: stroke)
            context.fill(Path(barRect), with: .color(blue))

            // Clean inner cutout above bar so the G opening is crisp
            var cut = Path()
            cut.addRect(CGRect(x: cx + r, y: cy - R, width: stroke + 1, height: R - stroke / 2))
            context.fill(cut, with: .color(.white))
        }
        .frame(width: 18, height: 18)
    }
}

// MARK: - Preview

#if DEBUG
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WelcomeView()
                .environmentObject(AuthViewModel())
        }
    }
}
#endif
