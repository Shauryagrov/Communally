//
//  JobHirerOnboardingView.swift
//  Communally
//
//  Created by Madhur Grover on 10/2/25.
//

import SwiftUI
import GoogleSignIn

struct JobHirerOnboardingView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var currentStep = 0
    @State private var age: Int = 18
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var companyName: String = ""
    @State private var selectedOpportunityTypes: Set<String> = []
    @State private var hasLocation: Bool = true
    @State private var termsAccepted: Bool = false
    @State private var locationPermissionGranted: Bool = false
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var bio = ""
    
    let opportunityTypes = [
        "Household Help", "Pet Care", "Cleaning",
        "Tutoring", "Tech Support", "Moving Help",
        "Childcare", "Handyman Work", "Event Help"
    ]
    
    var totalSteps: Int { 5 }
    
    var body: some View {
        ZStack {
            CommunallyTheme.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button to return to user type selection
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("← Back to Selection")
                                .font(CommunallyTheme.bodyFont)
                        }
                        .foregroundColor(CommunallyTheme.primaryGreen)
                    }
                    Spacer()
                }
                .padding(.horizontal, CommunallyTheme.padding)
                .padding(.top, CommunallyTheme.padding)
                
                // Progress indicator
                ProgressView(value: Double(currentStep), total: Double(totalSteps))
                    .progressViewStyle(LinearProgressViewStyle(tint: CommunallyTheme.primaryGreen))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal, CommunallyTheme.padding)
                    .padding(.top, 10)
                
                // Content
                TabView(selection: $currentStep) {
                    // Step 1: Profile Creation
                    profileCreationStep
                        .tag(0)
                    
                    // Step 2: Opportunity Information
                    opportunityInfoStep
                        .tag(1)
                    
                    // Step 3: Bio
                    bioStep
                        .tag(2)
                    
                    // Step 4: Location Permission
                    locationPermissionStep
                        .tag(3)
                    
                    // Step 5: Location & Terms
                    locationAndTermsStep
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                Spacer()
                
                // Navigation buttons
                navigationButtons
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }
    
    // MARK: - Profile Creation Step
    private var profileCreationStep: some View {
        VStack(spacing: 30) {
            Text("👋 Create Your Profile")
                .font(CommunallyTheme.titleFont)
                .foregroundColor(Color.black)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                // Profile Picture Picker
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
                
                // Name Fields
                VStack(spacing: 15) {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(WhiteTextFieldStyle())
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(WhiteTextFieldStyle())
                }
                
                // Age Stepper (18+ only)
                HStack {
                    Text("🎂 Age:")
                        .foregroundColor(Color.black)
                    Spacer()
                    Stepper("\(age)", value: $age, in: 18...100)
                        .foregroundColor(Color.black)
                }
                
                // Age Requirement Notice
                VStack(spacing: 10) {
                    Text("🔒 Age Requirement")
                        .font(CommunallyTheme.labelFont)
                        .foregroundColor(CommunallyTheme.primaryGreen)
                        .multilineTextAlignment(.center)
                    
                    Text("You must be 18 or older to post job opportunities and hire people.")
                        .font(CommunallyTheme.bodyFont)
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(CommunallyTheme.cornerRadius)
            }
        }
        .padding(CommunallyTheme.padding)
    }
    
    // MARK: - Opportunity Information Step
    private var opportunityInfoStep: some View {
        VStack(spacing: 30) {
            Text("🎯 What Help Do You Need?")
                .font(CommunallyTheme.titleFont)
                .foregroundColor(Color.black)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 60))
                    .foregroundColor(CommunallyTheme.primaryGreen)
                
                Text("Tell us what kind of help you're looking for")
                    .font(CommunallyTheme.subtitleFont)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 20) {
                    Text("✅ Select all that apply")
                        .font(CommunallyTheme.labelFont)
                        .foregroundColor(Color.black)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                        ForEach(opportunityTypes, id: \.self) { opportunityType in
                            OpportunityTypeCard(
                                opportunityType: opportunityType,
                                isSelected: selectedOpportunityTypes.contains(opportunityType)
                            ) {
                                if selectedOpportunityTypes.contains(opportunityType) {
                                    selectedOpportunityTypes.remove(opportunityType)
                                } else {
                                    selectedOpportunityTypes.insert(opportunityType)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(CommunallyTheme.padding)
    }
    
    // MARK: - Bio Step
    private var bioStep: some View {
        VStack(spacing: 30) {
            Text("📝 Your Bio")
                .font(CommunallyTheme.titleFont)
                .foregroundColor(Color.black)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                Image(systemName: "person.text.rectangle")
                    .font(.system(size: 60))
                    .foregroundColor(CommunallyTheme.primaryGreen)
                
                Text("Tell us about yourself and your business")
                    .font(CommunallyTheme.subtitleFont)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                
                Text("Write a brief description about yourself, your business, and what makes you a great employer.")
                    .font(CommunallyTheme.bodyFont)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextEditor(text: $bio)
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
        }
        .padding(CommunallyTheme.padding)
    }
    
    // MARK: - Location & Terms Step
    private var locationAndTermsStep: some View {
        VStack(spacing: 30) {
            Text("📍 Location & Terms")
                .font(CommunallyTheme.titleFont)
                .foregroundColor(Color.black)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                Image(systemName: "location.fill")
                    .font(.system(size: 60))
                    .foregroundColor(CommunallyTheme.primaryGreen)
                
                Text("📍 Location Preferences")
                    .font(CommunallyTheme.subtitleFont)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 15) {
                    Toggle("📍 Use Current Location", isOn: $hasLocation)
                        .toggleStyle(SwitchToggleStyle(tint: CommunallyTheme.primaryGreen))
                    
                    Text("Allow the app to use your current location to show nearby job seekers")
                        .font(CommunallyTheme.bodyFont)
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(CommunallyTheme.cornerRadius)
                
                // Terms Acceptance
                VStack(spacing: 15) {
                    HStack {
                        Toggle("", isOn: $termsAccepted)
                            .toggleStyle(SwitchToggleStyle(tint: CommunallyTheme.primaryGreen))
                        
                        Text("✅ I accept the Terms of Service and Privacy Policy")
                            .font(CommunallyTheme.bodyFont)
                            .foregroundColor(Color.black)
                    }
                    
                    Text("By accepting, you agree to comply with all local employment laws and regulations.")
                        .font(CommunallyTheme.captionFont)
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(CommunallyTheme.cornerRadius)
            }
        }
        .padding(CommunallyTheme.padding)
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button("← Back") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .buttonStyle(CommunallyTheme.secondaryButtonStyle)
            }
            
            Spacer()
            
            Button(currentStep == totalSteps - 1 ? "✨ Complete" : "Next →") {
                if currentStep == totalSteps - 1 {
                    completeOnboarding()
                } else {
                    withAnimation {
                        currentStep += 1
                    }
                }
            }
            .buttonStyle(CommunallyTheme.primaryButtonStyle)
            .disabled(!canProceed)
        }
        .padding(CommunallyTheme.padding)
    }
    
    // MARK: - Computed Properties
    private var canProceed: Bool {
        switch currentStep {
        case 0: // Profile Creation
            return !firstName.isEmpty && !lastName.isEmpty && age >= 18
        case 1: // Opportunity Information
            return !selectedOpportunityTypes.isEmpty
        case 2: // Bio
            return !bio.isEmpty
        case 3: // Location Permission
            return locationPermissionGranted
        case 4: // Location & Terms
            return termsAccepted
        default:
            return false
        }
    }
    
    // MARK: - Actions
    private func completeOnboarding() {
        guard let currentUser = authManager.currentUser else { return }
        
        let updatedUser = User(
            id: currentUser.id,
            email: currentUser.email,
            firstName: firstName,
            lastName: lastName,
            age: age,
            userType: .jobHirer,
            profileImageURL: currentUser.profileImageURL,
            profileImageData: profileImage?.jpegData(compressionQuality: 0.8),
            skills: [], // Job hirers don't need skills
            description: bio.isEmpty ? "Looking for help with: \(Array(selectedOpportunityTypes).joined(separator: ", "))" : bio,
            location: hasLocation ? Location(latitude: 0, longitude: 0, address: "Current Location") : nil,
            createdAt: currentUser.createdAt,
            isParentalApproved: nil, // Job hirers are always 18+
            hasCompletedOnboarding: true
        )
        
        authManager.completeOnboarding(user: updatedUser)
    }
}

// MARK: - Supporting Views
struct OpportunityTypeCard: View {
    let opportunityType: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(opportunityType)
                    .font(CommunallyTheme.bodyFont)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : Color.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? 
                AnyView(CommunallyTheme.buttonGradient) : 
                AnyView(Color.white)
            )
            .cornerRadius(CommunallyTheme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: CommunallyTheme.cornerRadius)
                    .stroke(isSelected ? Color.clear : Color.black, lineWidth: 1)
            )
            .shadow(color: .black.opacity(isSelected ? 0.2 : 0.1), radius: isSelected ? 4 : 2, x: 0, y: isSelected ? 3 : 1)
        }
    }
}

// MARK: - Location Permission Step
extension JobHirerOnboardingView {
    private var locationPermissionStep: some View {
        VStack(spacing: 30) {
            Text("📍 Enable Location Access")
                .font(CommunallyTheme.titleFont)
                .foregroundColor(Color.black)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                Image(systemName: "location.fill")
                    .font(.system(size: 60))
                    .foregroundColor(CommunallyTheme.primaryGreen)
                
                Text("Communally needs your location to show you nearby opportunities")
                    .font(CommunallyTheme.subtitleFont)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                
                Text("We'll only use your location to find jobs and volunteer opportunities in your area. You can change this setting anytime.")
                    .font(CommunallyTheme.bodyFont)
                    .foregroundColor(Color.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 15) {
                Button(action: {
                    requestLocationPermission()
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("🔓 Allow Location Access")
                    }
                    .font(CommunallyTheme.bodyFont)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: CommunallyTheme.buttonHeight)
                    .background(CommunallyTheme.buttonGradient)
                    .cornerRadius(CommunallyTheme.cornerRadius)
                }
                .disabled(locationPermissionGranted)
                
                if locationPermissionGranted {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(CommunallyTheme.primaryGreen)
                        Text("✅ Location access granted!")
                            .font(CommunallyTheme.bodyFont)
                            .foregroundColor(CommunallyTheme.primaryGreen)
                    }
                }
            }
        }
        .padding(CommunallyTheme.padding)
    }
    
    // MARK: - Location Permission Action
    private func requestLocationPermission() {
        // This will trigger the iOS location permission request
        LocationManager.shared.requestLocationPermission { granted in
            DispatchQueue.main.async {
                self.locationPermissionGranted = granted
            }
        }
    }
}

// MARK: - Custom Text Field Style
struct WhiteTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 1)
            )
            .foregroundColor(Color.black)
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    JobHirerOnboardingView()
        .environmentObject(AuthenticationManager.shared)
}

