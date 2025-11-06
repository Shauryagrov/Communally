//
//  DashboardView.swift
//  Communally
//
//  Created by Madhur Grover on 10/2/25.
//

import SwiftUI
import MapKit

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Map Tab
            MapTabView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
                .tag(0)
            
            // Opportunities Tab
            if authManager.currentUser?.userType == .jobSeeker {
                JobSeekerOpportunitiesView()
                    .tabItem {
                        Image(systemName: "briefcase.fill")
                        Text("Opportunities")
                    }
                    .tag(1)
            } else {
                JobHirerOpportunitiesView()
                    .tabItem {
                        Image(systemName: "briefcase.fill")
                        Text("Opportunities")
                    }
                    .tag(1)
            }
            
            // Messages Tab
            MessagingView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Messages")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(CommunallyTheme.primaryGreen)
        .onAppear {
            print("🏠 DashboardView: Appeared")
            print("🏠 DashboardView: User type = \(authManager.currentUser?.userType.rawValue ?? "unknown")")
            
            // Configure tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black.withAlphaComponent(0.95)
            
            // Set colors for tab bar items
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
            
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0.7, green: 0.9, blue: 0.3, alpha: 1.0)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(red: 0.7, green: 0.9, blue: 0.3, alpha: 1.0)]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct MapTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var opportunityManager = OpportunityManager.shared
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // San Francisco fallback
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var hasInitiallyCentered = false
    @State private var shouldCenterOnLocation = false
    @State private var selectedOpportunity: Opportunity?
    @State private var showOpportunityDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map View - Show opportunities for job seekers, only user location for hirers
                Map(coordinateRegion: $region, annotationItems: allAnnotations) { annotation in
                    MapAnnotation(coordinate: annotation.coordinate) {
                        if let opportunity = annotation.opportunity {
                            // Opportunity pin
                            OpportunityPinView(opportunity: opportunity)
                                .onTapGesture {
                                    selectedOpportunity = opportunity
                                    showOpportunityDetail = true
                                }
                        } else {
                            // User location pin with profile picture
                            UserLocationPinView(user: authManager.currentUser)
                        }
                    }
                }
                .ignoresSafeArea()
                .onAppear {
                    requestLocationPermission()
                }
                .onReceive(locationManager.$location) { location in
                    if let location = location {
                        // Update user location but don't auto-center unless it's the first time
                        userLocation = CLLocationCoordinate2D(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                        
                        // Only center automatically on first location update
                        if !hasInitiallyCentered {
                            hasInitiallyCentered = true
                            withAnimation(.easeInOut(duration: 1.0)) {
                                region.center = userLocation!
                            }
                        }
                        
                        // Center if user explicitly requested it
                        if shouldCenterOnLocation {
                            shouldCenterOnLocation = false
                            withAnimation(.easeInOut(duration: 1.0)) {
                                region.center = userLocation!
                            }
                        }
                    }
                }
                
                // Map Controls Overlay
                VStack {
                    HStack {
                        Spacer()
                        
                        // Location Button with improved design
                        Button(action: {
                            centerMapOnUserLocation()
                        }) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(CommunallyTheme.buttonGradient)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 0.1), value: UUID())
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showOpportunityDetail) {
                if let opportunity = selectedOpportunity {
                    NavigationView {
                        OpportunityDetailView(opportunity: opportunity)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func requestLocationPermission() {
        print("🗺️ MapTabView: Requesting location permission")
        locationManager.requestLocationPermissionWithoutCompletion()
    }
    
    private func centerMapOnUserLocation() {
        if let userLocation = userLocation {
            // Set flag to center on next location update
            shouldCenterOnLocation = true
            // Center immediately if we have location
            withAnimation(.easeInOut(duration: 1.0)) {
                region.center = userLocation
            }
        } else {
            // Request location if not available
            shouldCenterOnLocation = true
            locationManager.requestLocation()
        }
    }
    
    // MARK: - Computed Properties
    
    private var allAnnotations: [MapAnnotation] {
        var annotations: [MapAnnotation] = []
        
        // Add user location
        if let userLocation = userLocation {
            annotations.append(MapAnnotation(
                coordinate: userLocation,
                user: authManager.currentUser,
                opportunity: nil
            ))
        }
        
        // Add opportunities for job seekers only
        if authManager.currentUser?.userType == .jobSeeker {
            let opportunities = opportunityManager.getAllActiveOpportunities()
            for opportunity in opportunities {
                let coordinate = CLLocationCoordinate2D(
                    latitude: opportunity.location.latitude,
                    longitude: opportunity.location.longitude
                )
                annotations.append(MapAnnotation(
                    coordinate: coordinate,
                    user: nil,
                    opportunity: opportunity
                ))
            }
        }
        
        return annotations
    }
}

// MARK: - Supporting Data Structures

struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let user: User?
    let opportunity: Opportunity?
}

struct UserLocationPinView: View {
    let user: User?
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 6) {
            // Profile Picture or Default Image
            Group {
                if let profileImageData = user?.profileImageData,
                   let uiImage = UIImage(data: profileImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    // Default profile image
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
            )
            .overlay(
                Circle()
                    .stroke(CommunallyTheme.primaryGreen, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
            .scaleEffect(isAnimating ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: isAnimating)
            
            // Location indicator dot with subtle pulsing animation
            Circle()
                .fill(CommunallyTheme.primaryGreen)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .overlay(
                    Circle()
                        .stroke(CommunallyTheme.primaryGreen.opacity(0.2), lineWidth: 6)
                        .scaleEffect(isAnimating ? 1.3 : 1.0)
                        .opacity(isAnimating ? 0.0 : 0.4)
                        .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: isAnimating)
                )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = true
            }
        }
    }
}


struct OpportunityPinView: View {
    let opportunity: Opportunity
    
    var body: some View {
        VStack(spacing: 2) {
            // Icon background with category icon
            ZStack {
                // Outer glow
                Circle()
                    .fill(CommunallyTheme.primaryGreen.opacity(0.3))
                    .frame(width: 52, height: 52)
                    .blur(radius: 4)
                
                // Main circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(CommunallyTheme.primaryGreen, lineWidth: 2.5)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                // Icon
                Image(systemName: iconForJobType(opportunity.jobType))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(CommunallyTheme.primaryGreen)
            }
            
            // Pointer triangle
            Triangle()
                .fill(Color.white)
                .frame(width: 12, height: 8)
                .overlay(
                    Triangle()
                        .stroke(CommunallyTheme.primaryGreen, lineWidth: 2)
                )
                .offset(y: -2)
        }
        .scaleEffect(1.0)
    }
    
    private func iconForJobType(_ type: String) -> String {
        switch type.lowercased() {
        case "gardening": return "leaf.fill"
        case "pet care": return "pawprint.fill"
        case "tutoring": return "book.fill"
        case "moving help": return "box.truck.fill"
        case "painting": return "paintbrush.fill"
        case "babysitting": return "figure.2.and.child.holdinghands"
        case "event help": return "calendar.badge.plus"
        case "cleaning": return "sparkles"
        case "delivery": return "shippingbox.fill"
        default: return "briefcase.fill"
        }
    }
}

// Triangle shape for pin pointer
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct OpportunitiesTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            ZStack {
                CommunallyTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if authManager.currentUser?.userType == .jobSeeker {
                            JobSeekerOpportunitiesView()
                        } else {
                            JobHirerOpportunitiesView()
                        }
                        
                        Spacer(minLength: 100) // Space for tab bar
                    }
                    .padding(.horizontal, CommunallyTheme.padding)
                }
            }
            .navigationTitle("Opportunities")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct JobSeekerOpportunitiesView: View {
    @ObservedObject private var opportunityManager = OpportunityManager.shared
    @State private var searchText = ""
    
    private var allOpportunities: [Opportunity] {
        opportunityManager.getAllActiveOpportunities()
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Enhanced Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(CommunallyTheme.primaryGreen)
                    
                    TextField("Search opportunities...", text: $searchText)
                        .font(CommunallyTheme.bodyFont)
                        .foregroundColor(CommunallyTheme.darkGray)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(CommunallyTheme.primaryGreen.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                
                // Quick Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(title: "All", isSelected: true) {}
                        FilterChip(title: "Volunteer", isSelected: false) {}
                        FilterChip(title: "Remote", isSelected: false) {}
                    }
                    .padding(.horizontal, CommunallyTheme.padding)
                }
                
                // Opportunities List
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Available Opportunities")
                            .font(CommunallyTheme.titleFont)
                            .fontWeight(.bold)
                            .foregroundColor(CommunallyTheme.darkGray)
                        
                        Spacer()
                        
                        Text("\(allOpportunities.count) found")
                            .font(CommunallyTheme.captionFont)
                            .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
                    }
                    
                    if allOpportunities.isEmpty {
                        EmptyStateView(
                            title: "No opportunities yet",
                            message: "Check back later for new job postings in your area",
                            actionTitle: "Refresh",
                            action: {}
                        )
                    } else {
                        ForEach(allOpportunities) { opportunity in
                            NavigationLink(destination: OpportunityDetailView(opportunity: opportunity)) {
                                PostedOpportunityCard(opportunity: opportunity)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, CommunallyTheme.padding)
            .padding(.top, 32)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(CommunallyTheme.captionFont)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : CommunallyTheme.primaryGreen)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? CommunallyTheme.buttonGradient : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(CommunallyTheme.primaryGreen, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct JobHirerOpportunitiesView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @ObservedObject private var opportunityManager = OpportunityManager.shared
    @State private var showPostOpportunity = false
    
    private var userOpportunities: [Opportunity] {
        guard let userId = authManager.currentUser?.id else { return [] }
        return opportunityManager.getUserOpportunities(userId: userId)
    }
    
    private var totalApplicants: Int {
        userOpportunities.reduce(0) { $0 + $1.applicantCount }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.97).ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Enhanced Post New Opportunity Button
                Button(action: {
                    showPostOpportunity = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24, weight: .semibold))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Post New Opportunity")
                                .font(CommunallyTheme.titleFont)
                                .fontWeight(.bold)
                            
                            Text("Create a job or volunteer posting")
                                .font(CommunallyTheme.captionFont)
                                .opacity(0.8)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(CommunallyTheme.buttonGradient)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Quick Stats Cards
                HStack(spacing: 16) {
                    StatCard(
                        title: "Active Posts",
                        value: "\(userOpportunities.count)",
                        icon: "briefcase.fill",
                        color: CommunallyTheme.primaryGreen
                    )
                    
                    StatCard(
                        title: "Applications",
                        value: "\(totalApplicants)",
                        icon: "person.2.fill",
                        color: CommunallyTheme.secondaryGreen
                    )
                }
                
                // Posted Opportunities Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Your Posted Opportunities")
                            .font(CommunallyTheme.titleFont)
                            .fontWeight(.bold)
                            .foregroundColor(CommunallyTheme.darkGray)
                        
                        Spacer()
                        
                        if !userOpportunities.isEmpty {
                            Button(action: {}) {
                                Text("View All")
                                    .font(CommunallyTheme.captionFont)
                                    .fontWeight(.medium)
                                    .foregroundColor(CommunallyTheme.primaryGreen)
                            }
                        }
                    }
                    
                    if userOpportunities.isEmpty {
                        EmptyStateView(
                            title: "No opportunities posted",
                            message: "Create your first job posting to get started and connect with local talent",
                            actionTitle: "Refresh",
                            action: {}
                        )
                    } else {
                        ForEach(userOpportunities) { opportunity in
                            NavigationLink(destination: OpportunityDetailView(opportunity: opportunity)) {
                                PostedOpportunityCard(opportunity: opportunity)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, CommunallyTheme.padding)
            .padding(.top, 32)
        }
        .sheet(isPresented: $showPostOpportunity) {
            PostOpportunityView()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(CommunallyTheme.darkGray)
            
            Text(title)
                .font(CommunallyTheme.captionFont)
                .foregroundColor(CommunallyTheme.darkGray.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

struct PostedOpportunityCard: View {
    let opportunity: Opportunity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: iconForJobType(opportunity.jobType))
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(CommunallyTheme.primaryGreen)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(CommunallyTheme.primaryGreen.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(CommunallyTheme.primaryGreen.opacity(0.3), lineWidth: 1)
                            )
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(opportunity.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                    
                    Text(opportunity.locationName)
                        .font(CommunallyTheme.captionFont)
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(opportunity.displayPay)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(opportunity.isVolunteer ? CommunallyTheme.primaryGreen : Color(red: 0.15, green: 0.15, blue: 0.15))
                    
                    Text(opportunity.timeAgo)
                        .font(CommunallyTheme.captionFont)
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                }
            }
            
            // Description
            Text(opportunity.description)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.25))
                .lineLimit(2)
            
            // Status and Stats
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(opportunity.statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(opportunity.statusDisplay)
                        .font(CommunallyTheme.captionFont)
                        .foregroundColor(CommunallyTheme.darkGray.opacity(0.7))
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
                    
                    Text("\(opportunity.applicantCount) applicant\(opportunity.applicantCount == 1 ? "" : "s")")
                        .font(CommunallyTheme.captionFont)
                        .foregroundColor(CommunallyTheme.darkGray.opacity(0.7))
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 1.0, green: 1.0, blue: 1.0))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(CommunallyTheme.primaryGreen.opacity(0.4), lineWidth: 2)
                )
        )
        .compositingGroup()
        .cornerRadius(16)
        .shadow(color: CommunallyTheme.primaryGreen.opacity(0.3), radius: 16, x: 0, y: 8)
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)
    }
    
    private func iconForJobType(_ type: String) -> String {
        switch type.lowercased() {
        case "gardening": return "leaf.fill"
        case "pet care": return "pawprint.fill"
        case "tutoring": return "book.fill"
        case "moving help": return "box.truck.fill"
        case "painting": return "paintbrush.fill"
        case "babysitting": return "figure.2.and.child.holdinghands"
        case "event help": return "calendar.badge.plus"
        case "cleaning": return "sparkles"
        case "delivery": return "shippingbox.fill"
        default: return "briefcase.fill"
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthenticationManager.shared)
}
