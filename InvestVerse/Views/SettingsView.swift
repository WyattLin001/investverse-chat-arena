import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var selectedTab = 4
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Navigation Bar
                SettingsNavigationBar()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Section
                        ProfileSectionView(viewModel: viewModel)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        
                        // Settings Section
                        SettingsSectionView(viewModel: viewModel)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                }
                .background(Color(hex: "F5F5F5"))
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePickerView(selectedImage: $viewModel.profileImage)
        }
        .onAppear {
            viewModel.loadUserData()
        }
    }
}

struct SettingsNavigationBar: View {
    var body: some View {
        HStack {
            Text("設定")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.gray.opacity(0.3)),
            alignment: .bottom
        )
    }
}

struct ProfileSectionView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar Section
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.showImagePicker = true
                }) {
                    ZStack {
                        if let profileImage = viewModel.profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        // Camera overlay
                        Circle()
                            .fill(Color.black.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            )
                            .opacity(0.8)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Text("點擊更換頭像")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            // Nickname Section
            VStack(alignment: .leading, spacing: 8) {
                Text("暱稱")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                
                TextField("輸入暱稱", text: $viewModel.nickname)
                    .font(.system(size: 14))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: viewModel.nickname) { _ in
                        viewModel.saveUserData()
                    }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct SettingsSectionView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Language Setting
            SettingsRowView(
                title: "語言",
                subtitle: "Traditional Chinese",
                icon: "globe",
                showChevron: true
            ) {
                viewModel.showLanguageOptions = true
            }
            
            Divider()
            
            // Notification Setting
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "bell")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "00B900"))
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("推播通知")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("接收投資提醒和聊天訊息")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: $viewModel.notificationsEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "00B900")))
                    .onChange(of: viewModel.notificationsEnabled) { _ in
                        viewModel.saveUserData()
                    }
            }
            
            Divider()
            
            // Dark Mode Setting
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "moon")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "00B900"))
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("深色模式")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("切換至深色主題")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: $viewModel.darkModeEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "00B900")))
                    .onChange(of: viewModel.darkModeEnabled) { _ in
                        viewModel.saveUserData()
                    }
            }
            
            Divider()
            
            // Privacy Policy
            SettingsRowView(
                title: "隱私政策",
                subtitle: "查看我們的隱私條款",
                icon: "lock.shield",
                showChevron: true
            ) {
                viewModel.showPrivacyPolicy = true
            }
            
            Divider()
            
            // Terms of Service
            SettingsRowView(
                title: "服務條款",
                subtitle: "查看使用條款",
                icon: "doc.text",
                showChevron: true
            ) {
                viewModel.showTermsOfService = true
            }
            
            Divider()
            
            // App Version
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "00B900"))
                        .frame(width: 24)
                    
                    Text("應用版本")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("1.0.0")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .actionSheet(isPresented: $viewModel.showLanguageOptions) {
            ActionSheet(
                title: Text("選擇語言"),
                buttons: [
                    .default(Text("繁體中文")) {
                        viewModel.selectedLanguage = "繁體中文"
                        viewModel.saveUserData()
                    },
                    .default(Text("简体中文")) {
                        viewModel.selectedLanguage = "简体中文"
                        viewModel.saveUserData()
                    },
                    .default(Text("English")) {
                        viewModel.selectedLanguage = "English"
                        viewModel.saveUserData()
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $viewModel.showPrivacyPolicy) {
            WebView(url: "https://example.com/privacy")
        }
        .sheet(isPresented: $viewModel.showTermsOfService) {
            WebView(url: "https://example.com/terms")
        }
    }
}

struct SettingsRowView: View {
    let title: String
    let subtitle: String
    let icon: String
    let showChevron: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "00B900"))
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let webViewController = UIViewController()
        // In a real app, you would implement a proper web view here
        webViewController.view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "Web content would load here"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        webViewController.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: webViewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: webViewController.view.centerYAnchor)
        ])
        
        return webViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - View Model

class SettingsViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var profileImage: UIImage?
    @Published var notificationsEnabled: Bool = true
    @Published var darkModeEnabled: Bool = false
    @Published var selectedLanguage: String = "繁體中文"
    
    @Published var showImagePicker = false
    @Published var showLanguageOptions = false
    @Published var showPrivacyPolicy = false
    @Published var showTermsOfService = false
    
    private let userDefaults = UserDefaults.standard
    
    func loadUserData() {
        nickname = userDefaults.string(forKey: "user_nickname") ?? "投資新手小王"
        notificationsEnabled = userDefaults.bool(forKey: "notifications_enabled")
        darkModeEnabled = userDefaults.bool(forKey: "dark_mode_enabled")
        selectedLanguage = userDefaults.string(forKey: "selected_language") ?? "繁體中文"
        
        // Load profile image from UserDefaults
        if let imageData = userDefaults.data(forKey: "profile_image"),
           let image = UIImage(data: imageData) {
            profileImage = image
        }
    }
    
    func saveUserData() {
        userDefaults.set(nickname, forKey: "user_nickname")
        userDefaults.set(notificationsEnabled, forKey: "notifications_enabled")
        userDefaults.set(darkModeEnabled, forKey: "dark_mode_enabled")
        userDefaults.set(selectedLanguage, forKey: "selected_language")
        
        // Save profile image to UserDefaults
        if let image = profileImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            userDefaults.set(imageData, forKey: "profile_image")
        }
        
        userDefaults.synchronize()
    }
}

#Preview {
    SettingsView()
}