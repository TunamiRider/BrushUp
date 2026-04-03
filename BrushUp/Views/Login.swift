//
//  Login.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 3/30/26.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginWrapper: View {
    @State var isLoggedIn = false
    let firebaseService: FirebaseService
    
    var body: some View {
        NavigationStack {
            if isLoggedIn {
                MainScreen(isLoggedIn: $isLoggedIn)
            } else {
                ZStack {
                    AppConstants.spaceblack
                        .ignoresSafeArea()
                    Login(isLoggedIn: $isLoggedIn, firebaseService: firebaseService)
                }
            }
        }
    }
}
struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var errorMessage = ""
    @State private var isLoading = false

    @Binding var isLoggedIn: Bool  // track login state
    let firebaseService: FirebaseService

    var body: some View {
        //NavigationView {
            VStack(spacing: 20) {
                Spacer()
                Text("Brushup")
                    .font(.largeTitle)
                    .foregroundStyle(Color.white)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(isSignUp ? "Sign Up" : "Log In") {
                    isLoading = true
                    errorMessage = ""
                    if isSignUp {
                        signUp()
                    } else {
                        logIn()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppConstants.dustypink)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading)

                Button(isSignUp ? "Already have an account? Log In" : "Need an account? Sign Up") {
                    isSignUp.toggle()
                }
                .foregroundColor(.blue)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                //TEST
                Divider()
                    .padding(.vertical, 0.3)
                    .overlay(Color.white)
                
                Button("Log In without account") {
                    isLoading = true
                    isLoggedIn.toggle()
                    errorMessage = ""
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppConstants.dustypink)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading)
                //TEST

                
                if isLoading {
                    ProgressView("Loading…")
                }
                
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
            .padding()
            .frame(maxWidth: 600)
//            .navigationDestination(isPresented: $isLoggedIn) {
//                HomeView()  // your main app screen after login
//                //ProgressView("Loaded…")
//            }
        //}
        .onAppear {
            // optional: auto‑navigate if already signed in
            //isLoggedIn = true
            
//            if Auth.auth().currentUser != nil {
//                isLoggedIn.toggle()
//            }
            _ = Auth.auth().addStateDidChangeListener { _, user in
                isLoggedIn = user != nil
            }
        }
    }

    private func logIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    print(errorMessage)
                } else {
                    isLoggedIn = true
                    guard let uid = result?.user.uid else { return }
                    
                    Task {@MainActor in
                        do {
                            let success = try await firebaseService.setDeviceID(uid: uid)
                        } catch {
                            print("uid set failed")
                        }
                    }
                }
            }
        }
    }

    private func signUp() {
        // var uid: String = ""
        var createdAt: Date = Date()
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    isLoggedIn = true
                    guard let uid = result?.user.uid else { return }
                    createdAt = result?.user.metadata.creationDate! ?? Date()
                    //print("\(result?.user.uid) + TEST ")
                    //print(result?.user.metadata.creationDate)
                    Task {@MainActor in
                        do {
                            //print("saving ... ")
                            let success = try await firebaseService.singUp(uid: uid, createdAt: createdAt)
                            print(success)
                        } catch {
                            print("error")
                        }
                    }
                }
            }
        }
    }
}


#Preview {

    @Previewable @State var brushUpTimer = BrushUpTimer()
    @Previewable @State var appServices = AppServices()
    @Previewable @State var appActiveObserver = AppActiveObserver.shared
    
    var unsplashPhotoManager: UnsplashPhotoManager {
        UnsplashPhotoManager(
            unsplashService: appServices.unsplashService,
            firebaseService: appServices.firebaseService
        )
    }
    
    LoginWrapper(firebaseService: appServices.firebaseService)
        .environment(appServices)
        .environment(brushUpTimer)
        .environment(unsplashPhotoManager)
        .environment(appActiveObserver)
}

struct HomeView: View {
    @State private var isPremium = false

    var body: some View {
        VStack {
            Text("Welcome!")
                .font(.title)

            if isPremium {
                Text("Premium features enabled ✅")
            } else {
                Text("This is the free version.")
            }

            Button("Refresh user data") {
                loadUser()
            }
        }
        .onAppear {
            loadUser()
        }
    }

    private func loadUser() {
        //print("loading user")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            DispatchQueue.main.async {
                if let data = snapshot?.data() {
                    print(data)
                    isPremium = data["isPremium"] as? Bool ?? false
                }
            }
        }
    }
}
