import SwiftUI

struct LandingView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    LogoLockup()
                        .padding(.top, 48)

                    Text("Login")
                        .font(.system(size: 24, weight: .bold))

                    // MARK: - Fields
                    VStack(spacing: 16) {
                        // Email
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                            TextField("Email", text: $email)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .keyboardType(.emailAddress)
                        }
                        .padding()
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                                .background(Color.white.cornerRadius(14))
                        )

                        // Password
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundColor(.gray)
                            if showPassword {
                                TextField("Password", text: $password)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("Password", text: $password)
                            }
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                                .background(Color.white.cornerRadius(14))
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

                    // MARK: - Login Button
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

                    // MARK: - Divider
                    HStack {
                        Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
                        Text("or")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
                    }
                    .padding(.horizontal, 32)

                    // MARK: - Social Auth
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

                    // MARK: - Sign Up
                    HStack(spacing: 6) {
                        Text("Need an account?")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        Button("Sign up") {}
                            .font(.system(size: 14, weight: .bold))
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#if DEBUG
struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LandingView()
                .environmentObject(AuthViewModel())
        }
    }
}
#endif
