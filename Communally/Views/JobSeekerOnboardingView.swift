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
            CommunallyTheme.white
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Back button to return to user type selection
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("← Back to Selection")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(CommunallyTheme.primaryGreen)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Progress indicator
                ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                    .progressViewStyle(LinearProgressViewStyle(tint: CommunallyTheme.primaryGreen))
                    .padding(.horizontal)
                
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
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("← Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .foregroundColor(CommunallyTheme.primaryGreen)
                        .font(.system(size: 16, weight: .medium))
                    }
                    
                    Spacer()
                    
                    Button(currentStep == totalSteps - 1 ? "✨ Complete" : "Next →") {
                        print("🔘 Button pressed - currentStep: \(currentStep), totalSteps: \(totalSteps)")
                        if currentStep == totalSteps - 1 {
                            print("🔘 Complete button pressed - calling completeOnboarding()")
                            completeOnboarding()
                        } else {
                            print("🔘 Next button pressed - moving to step \(currentStep + 1)")
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .disabled(!canProceed)
                    .foregroundColor(canProceed ? .white : .gray)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(canProceed ? CommunallyTheme.primaryGreen : Color.gray.opacity(0.3))
                    .cornerRadius(8)
                    .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
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
