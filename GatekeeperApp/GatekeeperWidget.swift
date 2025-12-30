import WidgetKit
import SwiftUI

// MARK: - Models (shared with main app)

struct ServiceStatus: Codable {
    let name: String
    let is_alive: Bool
    let error: String?
}

struct State: Codable {
    let services: [ServiceStatus]
}

// MARK: - Widget State Provider

struct GatekeeperWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> GatekeeperWidgetEntry {
        GatekeeperWidgetEntry(date: Date(), state: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GatekeeperWidgetEntry) -> ()) {
        let state = loadState()
        let entry = GatekeeperWidgetEntry(date: Date(), state: state)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<GatekeeperWidgetEntry>) -> ()) {
        let state = loadState()
        let entry = GatekeeperWidgetEntry(date: Date(), state: state)
        
        // Update widget every 30 seconds
        let nextUpdate = Calendar.current.date(byAdding: .second, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadState() -> State? {
        let stateFile = "\(NSHomeDirectory())/.cache/gatekeeper/state.json"
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: stateFile))
            let decoder = JSONDecoder()
            let state = try decoder.decode(State.self, from: data)
            return state
        } catch {
            return nil
        }
    }
}

// MARK: - Widget Entry

struct GatekeeperWidgetEntry: TimelineEntry {
    let date: Date
    let state: State?
}

// MARK: - Widget Views

struct GatekeeperWidgetEntryView: View {
    var entry: GatekeeperWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        @unknown default:
            Text("Unsupported size")
        }
    }
}

// MARK: - Small Widget (Status only)

struct SmallWidgetView: View {
    var entry: GatekeeperWidgetEntry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("🔐")
                    .font(.system(size: 20))
                Text("Gatekeeper")
                    .font(.headline)
                Spacer()
            }
            
            Spacer()
            
            if let state = entry.state {
                let allAlive = state.services.allSatisfy { $0.is_alive }
                HStack {
                    Circle()
                        .fill(allAlive ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    
                    Text(allAlive ? "All OK" : "Issues")
                        .font(.system(.callout, design: .monospaced))
                }
            } else {
                Text("No data")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

// MARK: - Medium Widget (Services list)

struct MediumWidgetView: View {
    var entry: GatekeeperWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("🔐 Gatekeeper")
                    .font(.headline)
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            if let state = entry.state {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(state.services, id: \.name) { service in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(service.is_alive ? Color.green : Color.red)
                                .frame(width: 6, height: 6)
                            
                            Text(service.name)
                                .font(.system(.caption, design: .monospaced))
                            
                            Spacer()
                            
                            Text(service.is_alive ? "✅" : "❌")
                                .font(.system(size: 9))
                        }
                    }
                }
            } else {
                Text("Loading services...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

// MARK: - Large Widget (Detailed view)

struct LargeWidgetView: View {
    var entry: GatekeeperWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🔐 Gatekeeper Services")
                    .font(.headline)
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            if let state = entry.state {
                let aliveCount = state.services.filter { $0.is_alive }.count
                let totalCount = state.services.count
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Status")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(aliveCount)/\(totalCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(aliveCount == totalCount ? Color.green : Color.orange)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(aliveCount == totalCount ? "✅" : "⚠️")
                                .font(.system(size: 20))
                        )
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(state.services, id: \.name) { service in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(service.is_alive ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            
                            Text(service.name)
                                .font(.system(.body, design: .monospaced))
                            
                            Spacer()
                            
                            Text(service.is_alive ? "Alive" : "Dead")
                                .font(.caption)
                                .foregroundColor(service.is_alive ? .green : .red)
                        }
                    }
                }
            } else {
                VStack(alignment: .center) {
                    Spacer()
                    Text("Unable to load service status")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text("Make sure daemon is running")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }
        .padding()
    }
}

// MARK: - Widget Bundle

struct GatekeeperWidget: Widget {
    let kind: String = "GatekeeperWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GatekeeperWidgetProvider()) { entry in
            GatekeeperWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Gatekeeper")
        .description("Monitor service authentication status")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    GatekeeperWidget()
} timeline: {
    let mockState = State(services: [
        ServiceStatus(name: "AWS", is_alive: false, error: nil),
        ServiceStatus(name: "GitHub", is_alive: true, error: nil),
    ])
    GatekeeperWidgetEntry(date: Date(), state: mockState)
}
