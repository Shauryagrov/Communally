import SwiftUI
import CoreLocation

struct JobSeekerOnboardingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = 18
    @State private var termsAccepted = false
    @State private var parentalApproved = false
    @State private var selectedSkills: Set<String> = []
    @State private var description = ""
    @State private var locationPermissionGranted = false
    @State private var currentStep = 0
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    
    private let totalSteps: Int
    
    init() {
        // Calculate total steps based on age
        self.totalSteps = 18 >= 18 ? 4 : 5
    }
    
    private let availableSkills = [
        "Customer Service", "Sales", "Marketing", "Administration",
        "Teaching", "Tutoring", "Childcare", "Pet Care",
        "Food Service", "Retail", "Cleaning", "Gardening",
        "Photography", "Graphic Design", "Writing", "Translation",
        "Event Planning", "Social Media", "Data Entry", "Research"
    ]
    
    var body: some View {
        ZStack {
            // Soft gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.97, green: 0.99, blue: 0.95),
                    Color.white,
                    Color(red: 0.98, green: 1.0, blue: 0.96)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation bar
                VStack(spacing: 16) {
                // Back button to return to user type selection
                HStack {
                    Button(action: {
                            let impactLight = UIImpactFeedbackGenerator(style: .light)
                            impactLight.impactOccurred()
                        dismiss()
                    }) {
                            HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Back to Selection")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(CommunallyTheme.primaryGreen)
                    }
                    Spacer()
                        
                        // Step indicator
                        Text("Step \(currentStep + 1) of \(totalSteps)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                
                    // Enhanced Progress Bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
                                .frame(height: 6)
                            
                            // Progress fill with gradient
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            CommunallyTheme.primaryGreen,
                                            CommunallyTheme.secondaryGreen
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps), height: 6)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentStep)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                }
                .background(Color.white)
                
                // Step content
                Group {
                    switch currentStep {
                    case 0: // Profile Creation
                        profileCreationStep
                    case 1 where age < 18: // Parental Approval (only for minors)
                        parentalApprovalStep
                    case 1 where age >= 18, 2 where age < 18: // Skills Selection
                        skillsSelectionStep
                    case 2 where age >= 18, 3 where age < 18: // Description
                        descriptionStep
                    case 3 where age >= 18, 4 where age < 18: // Location Permission
                        locationPermissionStep
                    default:
                        EmptyView()
                    }
                }
                .frame(maxHeight: .infinity)
                
                // Enhanced Navigation buttons
                HStack(spacing: 12) {
                    if currentStep > 0 {
                        Button(action: {
                            let impactLight = UIImpactFeedbackGenerator(style: .light)
                            impactLight.impactOccurred()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                currentStep -= 1
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    }
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                            .frame(height: 56)
                            .frame(maxWidth: currentStep == totalSteps - 1 ? .infinity : 100)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 2)
                                    )
                            )
                        }
                    }
                    
                    Button(action: {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                        
                        print("🔘 Button pressed - currentStep: \(currentStep), totalSteps: \(totalSteps)")
                        if currentStep == totalSteps - 1 {
                            print("🔘 Complete button pressed - calling completeOnboarding()")
                            completeOnboarding()
                        } else {
                            print("🔘 Next button pressed - moving to step \(currentStep + 1)")
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                currentStep += 1
                            }
                        }
                    }) {
                        HStack(spacing: 10) {
                            Text(currentStep == totalSteps - 1 ? "Complete" : "Continue")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            
                            Image(systemName: currentStep == totalSteps - 1 ? "checkmark.circle.fill" : "arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    canProceed ?
                                    LinearGradient(
                                        colors: [
                                            CommunallyTheme.primaryGreen,
                                            CommunallyTheme.secondaryGreen
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.85, green: 0.85, blue: 0.85),
                                            Color(red: 0.8, green: 0.8, blue: 0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(
                                    color: canProceed ? CommunallyTheme.primaryGreen.opacity(0.3) : .clear,
                                    radius: 15,
                                    x: 0,
                                    y: 8
                                )
                        )
                    }
                    .disabled(!canProceed)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    Color.white
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
                )
            }
        }
        .navigationTitle("✨ Complete Your Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }
    
    // MARK: - Step Views
    
    private var profileCreationStep: some View {
        VStack(spacing: 20) {
            Text("👋 Tell us about yourself")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color.black)
            
            // Profile Image Picker
            VStack(spacing: 10) {
                Button(action: {
                    showingImagePicker = true
                }) {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(CommunallyTheme.primaryGreen, lineWidth: 3))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(CommunallyTheme.primaryGreen)
                            .overlay(Circle().stroke(CommunallyTheme.primaryGreen, lineWidth: 3))
                    }
                }
                
                Text("📸 Tap to add profile photo")
                    .font(.caption)
                    .foregroundColor(Color.black)
            }
            
            VStack(spacing: 16) {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(WhiteTextFieldStyle())
                
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(WhiteTextFieldStyle())
                
                HStack {
                    Text("🎂 Age:")
                        .foregroundColor(Color.black)
                    Spacer()
                    Stepper("\(age)", value: $age, in: 13...100)
                        .foregroundColor(Color.black)
                }
                
                Toggle("✅ I agree to the Terms and Conditions", isOn: $termsAccepted)
                    .foregroundColor(Color.black)
            }
        }
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }
    
    private var parentalApprovalStep: some View {
        VStack(spacing: 20) {
            Text("👨‍👩‍👧‍👦 Parental Approval Required")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color.black)
            
            Text("Since you're under 18, we need parental approval to continue.")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.black)
            
            Toggle("✅ I have parental approval to use this app", isOn: $parentalApproved)
                .foregroundColor(Color.black)
                .padding()
        }
    }
    
    private var skillsSelectionStep: some View {
        VStack(spacing: 20) {
            Text("🎯 Select Your Skills")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color.black)
            
            Text("Choose the skills you have experience with:")
                .foregroundColor(Color.black)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(availableSkills, id: \.self) { skill in
                    Button(action: {
                        if selectedSkills.contains(skill) {
                            selectedSkills.remove(skill)
                        } else {
                            selectedSkills.insert(skill)
                        }
                    }) {
                        Text(skill)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedSkills.contains(skill) ? CommunallyTheme.primaryGreen : Color.white)
                            .foregroundColor(selectedSkills.contains(skill) ? .white : Color.black)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var descriptionStep: some View {
        VStack(spacing: 20) {
            Text("📝 Your Bio")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color.black)
            
            Text("Write a brief description of your experience and what you're looking for:")
                .foregroundColor(Color.black)
            
            TextEditor(text: $description)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 1)
                )
                .foregroundColor(Color.black)
                .scrollContentBackground(.hidden)
        }
        .padding()
    }
    
    private var locationPermissionStep: some View {
        VStack(spacing: 20) {
            Text("📍 Location Access")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color.black)
            
            Text("We need access to your location to show you nearby opportunities and help you connect with local communities.")
                .multilineTextAlignment(.center)
                .foregroundColor(Color.black)
            
            Button("🔓 Allow Location Access") {
                print("📍 JobSeekerOnboardingView: Allow Location Access button pressed")
                requestLocationPermission()
            }
            .foregroundColor(.white)
            .padding()
            .background(CommunallyTheme.primaryGreen)
            .cornerRadius(8)
            .font(.system(size: 16, weight: .semibold))
            
            if locationPermissionGranted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("✅ Location access granted!")
                        .foregroundColor(.green)
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private var canProceed: Bool {
        let result: Bool
        switch currentStep {
        case 0: // Profile Creation
            result = !firstName.isEmpty && !lastName.isEmpty && termsAccepted
        case 1 where age < 18: // Parental Approval
            result = parentalApproved
        case 1 where age >= 18, 2 where age < 18: // Skills Selection
            result = !selectedSkills.isEmpty
        case 2 where age >= 18, 3 where age < 18: // Description
            result = !description.isEmpty
        case 3 where age >= 18, 4 where age < 18: // Location Permission
            result = locationPermissionGranted
        default:
            result = false
        }
        
        print("🔍 canProceed check - currentStep: \(currentStep), age: \(age), result: \(result)")
        return result
    }
    
    private func requestLocationPermission() {
        print("📍 JobSeekerOnboardingView: requestLocationPermission called")
        // This will trigger the iOS location permission request
        LocationManager.shared.requestLocationPermission { granted in
            DispatchQueue.main.async {
                print("📍 JobSeekerOnboardingView: Location permission result: \(granted)")
                self.locationPermissionGranted = granted
            }
        }
    }
    
    private func completeOnboarding() {
        print("🎯 JobSeekerOnboardingView: completeOnboarding called")
        
        guard let currentUser = authManager.currentUser else {
            print("❌ JobSeekerOnboardingView: No current user found")
            return
        }
        
        let updatedUser = User(
            id: currentUser.id,
            email: currentUser.email,
            firstName: firstName,
            lastName: lastName,
            age: age,
            userType: .jobSeeker,
            profileImageURL: currentUser.profileImageURL,
            profileImageData: profileImage?.jpegData(compressionQuality: 0.8),
            skills: Array(selectedSkills),
            description: description,
            location: LocationManager.shared.location.map { location in
                Location(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    address: nil
                )
            },
            createdAt: currentUser.createdAt,
            isParentalApproved: age < 18 ? parentalApproved : nil,
            hasCompletedOnboarding: true
        )
        
        print("🎯 JobSeekerOnboardingView: Calling authManager.completeOnboarding")
        authManager.completeOnboarding(user: updatedUser)
        print("🎯 JobSeekerOnboardingView: completeOnboarding call completed")
    }
}

#Preview {
    JobSeekerOnboardingView()
        .environmentObject(AuthenticationManager.shared)
}
