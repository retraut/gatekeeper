import SwiftUI
import AppKit

// MARK: - Models

struct ServiceStatus: Codable {
    let name: String
    let is_alive: Bool
    let error: String?
}

struct State: Codable {
    let services: [ServiceStatus]
}

// MARK: - View Models

class GatekeeperViewModel: ObservableObject {
    @Published var state: State?
    @Published var isLoading = false
    @Published var error: String?
    
    private var timer: Timer?
    
    init() {
        loadState()
        // Refresh every 10 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.loadState()
        }
    }
    
    func loadState() {
        let stateFile = "\(NSHomeDirectory())/.cache/gatekeeper/state.json"
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: stateFile))
            let decoder = JSONDecoder()
            let state = try decoder.decode(State.self, from: data)
            DispatchQueue.main.async {
                self.state = state
                self.error = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.error = "Unable to load state"
                self.state = nil
            }
        }
    }
    
    var statusIcon: String {
        guard let state = state else { return "🔐" }
        let allAlive = state.services.allSatisfy { $0.is_alive }
        return allAlive ? "✅" : "⚠️"
    }
    
    var statusColor: Color {
        guard let state = state else { return .gray }
        let allAlive = state.services.allSatisfy { $0.is_alive }
        return allAlive ? .green : .red
    }
    
    deinit {
        timer?.invalidate()
    }
}

// MARK: - Menu Bar Content

struct MenuBarView: View {
    @ObservedObject var viewModel: GatekeeperViewModel
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("🔐 Gatekeeper")
                    .font(.headline)
                Spacer()
                Button(action: { viewModel.loadState() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Divider()
            
            // Services List
            if let state = viewModel.state {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(state.services, id: \.name) { service in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(service.is_alive ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            
                            Text(service.name)
                                .font(.system(.body, design: .monospaced))
                            
                            Spacer()
                            
                            Text(service.is_alive ? "✅" : "❌")
                                .font(.system(size: 10))
                        }
                        .padding(.vertical, 4)
                    }
                }
            } else if let error = viewModel.error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            } else {
                Text("Loading...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            // Actions
            VStack(alignment: .leading, spacing: 6) {
                Button(action: { openDaemon() }) {
                    Label("Start Daemon", systemImage: "play.circle")
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { openConfig() }) {
                    Label("Edit Config", systemImage: "gearshape")
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { viewLogs() }) {
                    Label("View Logs", systemImage: "doc.text")
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Label("Quit", systemImage: "xmark.circle")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .font(.system(size: 11))
        }
        .padding(12)
        .frame(width: 250)
    }
    
    private func openDaemon() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/Users/retraut/.local/bin/gatekeeper")
        task.arguments = ["daemon"]
        try? task.run()
    }
    
    private func openConfig() {
        let configPath = "\(NSHomeDirectory())/.config/gatekeeper/config.yaml"
        NSWorkspace.shared.open(URL(fileURLWithPath: configPath))
    }
    
    private func viewLogs() {
        let logsPath = "\(NSHomeDirectory())/.cache/gatekeeper/gatekeeper.log"
        NSWorkspace.shared.open(URL(fileURLWithPath: logsPath))
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        let viewModel = GatekeeperViewModel()
        
        // Create menu bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "🔐"
        
        // Create popover
        let popover = NSPopover()
        popover.contentViewController = NSHostingController(rootView: MenuBarView(viewModel: viewModel))
        popover.behavior = .transient
        self.popover = popover
        
        // Setup menu bar button action
        statusItem?.button?.action = #selector(togglePopover)
        statusItem?.button?.target = self
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}

// MARK: - App

@main
struct GatekeeperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
