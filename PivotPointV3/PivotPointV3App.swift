import SwiftUI

@main
struct PivotPointV3App: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var userSettings = UserSettings()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut) {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    MainMenuView()
                        .environmentObject(userSettings)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .inactive || newPhase == .background {
                try? persistenceController.container.viewContext.save()
            }
        }
    }
}
