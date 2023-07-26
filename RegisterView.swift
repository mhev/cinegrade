//import SwiftUI
//
//struct RegisterView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var confirmPassword: String = ""
//    @State private var isEmailValid = true
//    @State private var isPasswordValid = true
//    @State private var isConfirmPasswordValid = true
//    @State private var isPasswordsMatching = true
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                TextField("Email", text: $email)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//                    .autocapitalization(.none)
//                    .keyboardType(.emailAddress)
//                    .textContentType(.emailAddress)
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(isEmailValid ? Color.clear : Color.red, lineWidth: 1)
//                    )
//
//                SecureField("Password", text: $password)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//                    .textContentType(.newPassword)
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(isPasswordValid ? Color.clear : Color.red, lineWidth: 1)
//                    )
//
//                SecureField("Confirm Password", text: $confirmPassword)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//                    .textContentType(.newPassword)
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(isConfirmPasswordValid ? Color.clear : Color.red, lineWidth: 1)
//                    )
//
//                Button(action: {
//                    // Perform validation checks
//                    isEmailValid = isValidEmail(email)
//                    isPasswordValid = isValidPassword(password)
//                    isConfirmPasswordValid = isValidPassword(confirmPassword)
//                    isPasswordsMatching = password == confirmPassword
//
//                    if isEmailValid && isPasswordValid && isConfirmPasswordValid && isPasswordsMatching {
//                        // Perform registration logic here
//                        registerUser(email: email, password: password)
//                    }
//                }) {
//                    Text("Submit")
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.blue)
//                        .cornerRadius(8)
//                }
//                .padding(.top, 16)
//
//                Spacer()
//            }
//            .padding()
//            .navigationBarTitle("Register", displayMode: .inline)
//            .navigationBarItems(leading: Button("Back") {
//                presentationMode.wrappedValue.dismiss()
//            })
//        }
//    }
//
//    // Validation functions
//    private func isValidEmail(_ email: String) -> Bool {
//        // You can use a regular expression or any other method to validate the email format.
//        // For simplicity, let's use a basic check for this example.
//        return email.contains("@") && email.contains(".")
//    }
//
//    private func isValidPassword(_ password: String) -> Bool {
//        let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{8,}$"
//        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
//    }
//
//    // Networking function to register user
//    private func registerUser(email: String, password: String) {
//        let urlString = "http://localhost:3000/register"
//
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//
//        let parameters: [String: Any] = [
//            "email": email,
//            "password": password
//        ]
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
//            request.httpBody = jsonData
//        } catch {
//            print("Error creating JSON data: \(error)")
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                // Handle the error and show an alert if registration fails
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//
//            if let data = data {
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    // Process the response JSON if needed
//                    print("Response JSON: \(json)")
//
//                    // Registration successful, handle response if needed
//                    print("Registration successful")
//
//                    // Dismiss the RegisterView and navigate back to the ContentView
//                    presentationMode.wrappedValue.dismiss()
//
//                    // You can navigate to another screen or show an alert to indicate success.
//                } catch {
//                    // Handle the error if JSON decoding fails
//                    print("Error decoding JSON: \(error)")
//                }
//            }
//        }.resume()
//    }
//}
