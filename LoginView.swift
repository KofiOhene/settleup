import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        LogoLockup()
                            .padding(.top, 12)

                        Text("Login")
                            .font(.system(size: 24, weight: .semibold))
                            .padding(.top, 4)

                        VStack(spacing: 16) {
                            IconTextField(
                                systemIcon: "envelope",
                                placeholder: "Email",
                                text: $email
                            )

                            IconSecureField(
                                systemIcon: "lock",
                                placeholder: "Password",
                                text: $password
                            )

                            if let error = authVM.errorMessage {
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }

                            HStack {
                                Spacer()
                                Button("Forgot Password?") {}
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 20)

                        Button {
                            Task {
                                await authVM.signIn(email: email, password: password)
                            }
                        } label: {
                            Text(authVM.isLoading ? "Signing in..." : "Login")
                                .font(.system(size: 17, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .disabled(authVM.isLoading)
                        .padding(.horizontal, 20)

                        DividerWithLabel(label: "or")
                            .padding(.horizontal, 32)

                        VStack(spacing: 14) {
                            Button {
                                // Google sign-in
                            } label: {
                                AuthButtonContent(
                                    label: "Continue with Google",
                                    icon: "google",
                                    style: .light
                                )
                            }

                            Button {
                                // Apple sign-in
                            } label: {
                                AuthButtonContent(
                                    label: "Continue with Apple",
                                    icon: "apple.logo",
                                    style: .dark
                                )
                            }

                            Button {
                                // Guest access
                            } label: {
                                AuthButtonContent(
                                    label: "Continue As Guest",
                                    icon: "person.fill",
                                    style: .light
                                )
                            }
                        }
                        .padding(.horizontal, 20)

                        HStack(spacing: 6) {
                            Text("Need an account?")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                            Button("Sign up") {}
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
        .navigationBarHidden(true)
    }
}

// MARK: - Form Fields

private struct IconTextField: View {
    var systemIcon: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemIcon)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
        .padding()
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                .background(Color.white.cornerRadius(14))
        )
    }
}

private struct IconSecureField: View {
    var systemIcon: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemIcon)
                .foregroundColor(.gray)
            SecureField(placeholder, text: $text)
        }
        .padding()
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                .background(Color.white.cornerRadius(14))
        )
    }
}

private struct DividerWithLabel: View {
    var label: String
    var body: some View {
        HStack {
            Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginView()
                .environmentObject(AuthViewModel())
        }
    }
}
#endif
