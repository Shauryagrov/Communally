//
//  PostOpportunityView.swift
//  Communally
//
//  Created for minimalistic job posting
//

import SwiftUI
import MapKit

struct PostOpportunityView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @ObservedObject private var opportunityManager = OpportunityManager.shared
    
    // Location
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var locationName: String = ""
    @State private var showLocationPicker = false
    
    // Pay
    @State private var isVolunteer = true
    @State private var payAmount: String = ""
    
    // Job Type
    @State private var selectedJobType: JobType = .other
    @State private var jobDescription: String = ""
    
    // Error handling
    @State private var showError = false
    @State private var errorMessage = ""
    
    enum JobType: String, CaseIterable {
        case gardening = "Gardening"
        case petCare = "Pet Care"
        case tutoring = "Tutoring"
        case moving = "Moving Help"
        case painting = "Painting"
        case babysitting = "Babysitting"
        case eventHelp = "Event Help"
        case cleaning = "Cleaning"
        case delivery = "Delivery"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .gardening: return "leaf.fill"
            case .petCare: return "pawprint.fill"
            case .tutoring: return "book.fill"
            case .moving: return "box.truck.fill"
            case .painting: return "paintbrush.fill"
            case .babysitting: return "figure.2.and.child.holdinghands"
            case .eventHelp: return "calendar.badge.plus"
            case .cleaning: return "sparkles"
            case .delivery: return "shippingbox.fill"
            case .other: return "briefcase.fill"
            }
        }
    }

    var body: some View {
        NavigationView {
            mainContent
                .navigationTitle("Post Opportunity")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(CommunallyTheme.darkGray)
                    }
                }
                .sheet(isPresented: $showLocationPicker) {
                    LocationPickerView(
                        selectedLocation: $selectedLocation,
                        locationName: $locationName,
                        isPresented: $showLocationPicker
                    )
                }
        }
    }
    
    private var mainContent: some View {
        ZStack {
            CommunallyTheme.backgroundGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    locationSection
                    paySection
                    jobTypeSection
                    descriptionSection
                    postButton
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Location Section
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Where?")
            
            locationButton
        }
    }
    
    private var locationButton: some View {
        Button(action: {
            showLocationPicker = true
        }) {
            HStack {
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                    .foregroundColor(CommunallyTheme.primaryGreen)
                
                Text(locationName.isEmpty ? "Select Location" : locationName)
                    .font(CommunallyTheme.bodyFont)
                    .foregroundColor(locationName.isEmpty ? CommunallyTheme.darkGray.opacity(0.5) : CommunallyTheme.darkGray)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(CommunallyTheme.darkGray.opacity(0.4))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Pay Section
    private var paySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("How Much?")
            
            VStack(spacing: 12) {
                volunteerButton
                paidButton
            }
        }
    }
    
    private var volunteerButton: some View {
        Button(action: {
            isVolunteer = true
            payAmount = ""
        }) {
            HStack {
                checkmarkIcon(isVolunteer)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Volunteer")
                        .font(CommunallyTheme.bodyFont)
                        .fontWeight(.semibold)
                        .foregroundColor(CommunallyTheme.darkGray)
                    
                    Text("Unpaid opportunity")
                        .font(CommunallyTheme.captionFont)
                        .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isVolunteer ? CommunallyTheme.primaryGreen : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var paidButton: some View {
        Button(action: {
            isVolunteer = false
        }) {
            HStack {
                checkmarkIcon(!isVolunteer)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Paid")
                        .font(CommunallyTheme.bodyFont)
                        .fontWeight(.semibold)
                        .foregroundColor(CommunallyTheme.darkGray)
                    
                    if !isVolunteer {
                        payAmountField
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(!isVolunteer ? CommunallyTheme.primaryGreen : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var payAmountField: some View {
        HStack(spacing: 8) {
            Text("$")
                .font(CommunallyTheme.bodyFont)
                .foregroundColor(CommunallyTheme.darkGray)
            
            TextField("50", text: $payAmount)
                .font(CommunallyTheme.bodyFont)
                .keyboardType(.decimalPad)
                .foregroundColor(CommunallyTheme.darkGray)
                .frame(width: 80)
            
            Text("total")
                .font(CommunallyTheme.captionFont)
                .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
        }
    }
    
    // MARK: - Job Type Section
    private var jobTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("What Kind of Help?")
            
            jobTypeGrid
        }
    }
    
    private var jobTypeGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(JobType.allCases, id: \.self) { type in
                jobTypeCard(type)
            }
        }
    }
    
    private func jobTypeCard(_ type: JobType) -> some View {
        Button(action: {
            selectedJobType = type
        }) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 28))
                    .foregroundColor(selectedJobType == type ? CommunallyTheme.primaryGreen : CommunallyTheme.darkGray.opacity(0.5))
                
                Text(type.rawValue)
                    .font(CommunallyTheme.captionFont)
                    .foregroundColor(CommunallyTheme.darkGray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedJobType == type ? CommunallyTheme.primaryGreen : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Details")
            
            descriptionField
        }
    }
    
    private var descriptionField: some View {
        ZStack(alignment: .topLeading) {
            // White background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            
            if jobDescription.isEmpty {
                Text("Describe what you need help with...")
                    .font(CommunallyTheme.bodyFont)
                    .foregroundColor(Color.gray.opacity(0.5))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            
            TextEditor(text: $jobDescription)
                .font(CommunallyTheme.bodyFont)
                .foregroundColor(.black)
                .frame(height: 120)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
        }
    }
    
    // MARK: - Post Button
    private var postButton: some View {
        Button(action: postOpportunity) {
            Text("Post Opportunity")
                .font(CommunallyTheme.bodyFont)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canPost ? CommunallyTheme.primaryGreen : CommunallyTheme.darkGray.opacity(0.3))
                .cornerRadius(12)
                .shadow(color: canPost ? CommunallyTheme.primaryGreen.opacity(0.3) : .clear, radius: 12, x: 0, y: 6)
        }
        .disabled(!canPost)
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Views
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(CommunallyTheme.titleFont)
            .fontWeight(.bold)
            .foregroundColor(CommunallyTheme.darkGray)
    }
    
    private func checkmarkIcon(_ isSelected: Bool) -> some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 24))
            .foregroundColor(isSelected ? CommunallyTheme.primaryGreen : CommunallyTheme.darkGray.opacity(0.3))
    }
    
    // MARK: - Computed Properties
    private var canPost: Bool {
        selectedLocation != nil &&
        !locationName.isEmpty &&
        (isVolunteer || !payAmount.isEmpty) &&
        !jobDescription.isEmpty
    }
    
    // MARK: - Actions
    private func postOpportunity() {
        guard let selectedLocation = selectedLocation,
              let userId = authManager.currentUser?.id else {
            print("❌ Missing required data")
            return
        }
        
        let location = Location(
            latitude: selectedLocation.latitude,
            longitude: selectedLocation.longitude,
            address: locationName
        )
        
        opportunityManager.postOpportunity(
            title: "\(selectedJobType.rawValue) Needed",
            description: jobDescription,
            location: location,
            locationName: locationName,
            isVolunteer: isVolunteer,
            payAmount: isVolunteer ? nil : payAmount,
            jobType: selectedJobType.rawValue,
            hirerId: userId
        )
        
        print("📤 Successfully posted opportunity!")
        dismiss()
    }
}

// MARK: - Location Picker View
struct LocationPickerView: View {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var locationName: String
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                mapView
                
                VStack {
                    Spacer()
                    confirmButton
                        .padding()
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private var mapView: some View {
        Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true)
            .ignoresSafeArea()
            .onTapGesture {
                handleMapTap()
            }
            .overlay(centerPin)
    }
    
    private var centerPin: some View {
        Image(systemName: "mappin.circle.fill")
            .font(.system(size: 40))
            .foregroundColor(CommunallyTheme.primaryGreen)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    private var confirmButton: some View {
        Button(action: confirmLocation) {
            Text("Confirm Location")
                .font(CommunallyTheme.bodyFont)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(CommunallyTheme.primaryGreen)
                .cornerRadius(12)
                .shadow(color: CommunallyTheme.primaryGreen.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func handleMapTap() {
        let center = region.center
        selectedLocation = center
        
        // Reverse geocode to get address
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                var components: [String] = []
                if let name = placemark.name {
                    components.append(name)
                }
                if let locality = placemark.locality {
                    components.append(locality)
                }
                locationName = components.joined(separator: ", ")
            }
        }
    }
    
    private func confirmLocation() {
        if selectedLocation == nil {
            handleMapTap()
        }
        isPresented = false
    }
}

// MARK: - Preview
#Preview {
    PostOpportunityView()
}
