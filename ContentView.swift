import SwiftUI

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    @State private var isConfirmPasswordValid = true
    @State private var isPasswordsMatching = true
    @Binding var isRegistered: Bool // Add a binding for isRegistered
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isEmailValid ? Color.clear : Color.red, lineWidth: 1)
                    )
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .textContentType(.newPassword)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isPasswordValid ? Color.clear : Color.red, lineWidth: 1)
                    )
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .textContentType(.newPassword)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isConfirmPasswordValid ? Color.clear : Color.red, lineWidth: 1)
                    )
                
                Button(action: {
                    // Perform validation checks
                    isEmailValid = isValidEmail(email)
                    isPasswordValid = isValidPassword(password)
                    isConfirmPasswordValid = isValidPassword(confirmPassword)
                    isPasswordsMatching = password == confirmPassword
                    
                    if isEmailValid && isPasswordValid && isConfirmPasswordValid && isPasswordsMatching {
                        // Perform registration logic here
                        registerUser(email: email, password: password)
                    }
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 16)
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Register", displayMode: .inline)
            .navigationBarItems(leading: Button("Back") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // Validation functions
    private func isValidEmail(_ email: String) -> Bool {
        // You can use a regular expression or any other method to validate the email format.
        // For simplicity, let's use a basic check for this example.
        return email.contains("@") && email.contains(".")
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    // Networking function to register user
    private func registerUser(email: String, password: String) {
        let urlString = "http://localhost:3000/register"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error creating JSON data: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // Handle the error and show an alert if registration fails
                print("Error: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    // Process the response JSON if needed
                    print("Response JSON: \(json)")

                    // Registration successful, handle response if needed
                    print("Registration successful")
                    isRegistered = true // Set isRegistered to true after successful registration

                    // Dismiss the RegisterView and navigate back to the ContentView
                    presentationMode.wrappedValue.dismiss()

                    // You can navigate to another screen or show an alert to indicate success.
                } catch {
                    // Handle the error if JSON decoding fails
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
}

struct ContentView: View {
    @State private var searchText: String = ""
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false // Read the login status
    @State private var isRegistering = false
    @State private var topRatedMovies: [Movie] = []
    
    var filteredMovies: [Movie] {
        if searchText.isEmpty {
            return topRatedMovies
        } else {
            return topRatedMovies.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.top, 16)
                
                Text("Top rated movies")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                
                ScrollView {
                                    ForEach(filteredMovies.prefix(5)) { movie in
                                        VStack(alignment: .leading) {
                                            Text(movie.title)
                                                .font(.headline)
                                            
                                            if let rating = movie.rating {
                                                Text("Rating: \(rating, specifier: "%.1f")")
                                                    .foregroundColor(.gray)
                                            } else {
                                                Text("Rating: N/A")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding()
                                        .border(Color.gray, width: 1)
                                    }
                                }
                                .padding(.top, 16)
                                .padding(.horizontal, 16)
                
                Spacer()
                
                HStack {
                    // If the user is logged in, show a Logout button; otherwise, show the Register button
                    if isLoggedIn {
                        Button(action: {
                            // Perform logout here
                            UserDefaults.standard.set(false, forKey: "isLoggedIn")
                            isLoggedIn = false
                        }) {
                            Text("Logout")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    } else {
                        Button(action: {
                            isRegistering = true
                        }) {
                            Text("Register")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        .sheet(isPresented: $isRegistering, content: {
                            // Present the RegisterView as a sheet
                            RegisterView(isRegistered: $isRegistering) // Pass the binding here
                        })
                    }
                }
                .padding(.bottom, 16)
                
            }
            .padding(.horizontal, 16)
            .navigationBarTitle("Top Movies", displayMode: .inline)
            .onAppear {
                // Fetch top-rated movies data here
                fetchTopRatedMovies()
            }
        }
    }
    
    private func fetchTopRatedMovies() {
        // Create an instance of MovieAPI and fetch top-rated movies
        let movieAPI = MovieAPI()
        movieAPI.fetchTopRatedMovies { movies in
            DispatchQueue.main.async {
                self.topRatedMovies = movies
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $text)
                .foregroundColor(.primary)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal, 16)
    }
}

struct Movie: Identifiable, Decodable {
    var id = UUID()
    var title: String
    var rating: Double? // Use an optional Double to represent "N/A" rating initially
}


class MovieAPI {
    private let apiKey = "d94f6ed94bd565126a387795d3c6b3b8"
    
    func fetchTopRatedMovies(completion: @escaping ([Movie]) -> Void) {
        let urlString = "https://api.themoviedb.org/3/movie/top_rated"
        
        guard var urlComponents = URLComponents(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion([])
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let movies = try decoder.decode([Movie].self, from: data)
                completion(movies)
            } catch {
                print("Error decoding JSON: \(error)")
                completion([])
            }
        }.resume()
    }
}
