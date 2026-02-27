import SwiftUI

struct UsagePopoverView: View {
    @ObservedObject var viewModel: UsageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            ToolUsageSectionView(title: "Codex", state: viewModel.codexState)
            ToolUsageSectionView(title: "Claude", state: viewModel.claudeState)

            Divider()

            HStack {
                if let lastUpdated = viewModel.lastUpdated {
                    Text("Updated \(lastUpdated.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Not refreshed yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .keyboardShortcut("q")
            }
        }
        .padding(14)
        .frame(width: 360)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("RateLimited")
                    .font(.headline)
                Text("AI usage limits")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if viewModel.isRefreshing {
                ProgressView()
                    .controlSize(.small)
            }

            Button {
                Task {
                    await viewModel.refresh()
                }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .labelStyle(.titleAndIcon)
            .disabled(viewModel.isRefreshing)
        }
    }
}

#if DEBUG
#Preview("Usage Popover") {
    UsagePopoverView(viewModel: .previewMock())
}

#Preview("Usage Popover Errors") {
    UsagePopoverView(viewModel: .previewError())
}
#endif

private struct ToolUsageSectionView: View {
    let title: String
    let state: ToolUsageState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.weight(.semibold))

            if let snapshot = state.snapshot {
                UsageBarRow(title: "5-hour", window: snapshot.fiveHour)
                UsageBarRow(title: "Weekly", window: snapshot.weekly)
            } else if let error = state.errorMessage {
                Text(error)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Loading...")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            if let error = state.errorMessage, state.snapshot != nil {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}

private struct UsageBarRow: View {
    let title: String
    let window: UsageWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.subheadline.weight(.medium))

                Spacer()

                Text("\(Int(window.usedPercent.rounded()))% used")
                    .font(.subheadline.monospacedDigit())
            }

            ProgressView(value: window.usedPercent, total: 100)
                .tint(tintColor)

            if let resetDate = window.resetDate {
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    Text("Resets in \(UsageDisplayFormatter.timeRemainingString(until: resetDate, now: context.date))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Reset time unavailable")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var tintColor: Color {
        switch window.usedPercent {
        case 90...:
            .red
        case 75...:
            .orange
        default:
            .blue
        }
    }
}
