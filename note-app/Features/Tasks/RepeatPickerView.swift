import SwiftUI

struct RepeatPickerView: View {
    @Binding var rule: RepeatRule?

    private var isCustom: Bool {
        guard let rule else { return false }
        return !RepeatRule.presets.contains { $0.rule.matches(rule) }
    }

    private var customRule: Binding<RepeatRule> {
        Binding {
            rule ?? .everyWeek
        } set: { newValue in
            rule = newValue
        }
    }

    private var hasEndDate: Binding<Bool> {
        Binding {
            rule?.endDate != nil
        } set: { on in
            rule?.endDate = on ? Calendar.current.date(byAdding: .month, value: 1, to: .now) : nil
        }
    }

    private var endDate: Binding<Date> {
        Binding {
            rule?.endDate ?? .now
        } set: { newValue in
            rule?.endDate = newValue
        }
    }

    var body: some View {
        Form {
            Section {
                option("Never", isSelected: rule == nil) {
                    rule = nil
                }

                ForEach(RepeatRule.presets, id: \.title) { preset in
                    option(preset.title, isSelected: rule.map { $0.matches(preset.rule) } ?? false) {
                        var newRule = preset.rule
                        newRule.endDate = rule?.endDate
                        rule = newRule
                    }
                }

                option("Custom", isSelected: isCustom) {
                    if !isCustom {
                        var newRule = RepeatRule(frequency: .weekly, interval: 1, weekdays: [Calendar.current.component(.weekday, from: .now)])
                        newRule.endDate = rule?.endDate
                        rule = newRule
                    }
                }
            }

            if rule != nil {
                Section("Custom") {
                    Picker("Frequency", selection: customRule.frequency) {
                        ForEach(RepeatRule.Frequency.allCases) { frequency in
                            Text(frequency.title).tag(frequency)
                        }
                    }
                    .onChange(of: rule?.frequency) { _, frequency in
                        if frequency != .weekly {
                            rule?.weekdays = []
                        }
                    }

                    Stepper(value: customRule.interval, in: 1...99) {
                        Text("Every \(customRule.wrappedValue.interval) \(customRule.wrappedValue.frequency.unit(customRule.wrappedValue.interval))")
                    }

                    if customRule.wrappedValue.frequency == .weekly {
                        WeekdayPicker(selection: customRule.weekdays)
                    }
                }

                Section {
                    Toggle("End Repeat", isOn: hasEndDate.animation())
                    if rule?.endDate != nil {
                        DatePicker("End Date", selection: endDate, in: Date.now..., displayedComponents: .date)
                    }
                } footer: {
                    if let rule {
                        Text(rule.summary)
                    }
                }
            }
        }
        .navigationTitle("Repeat")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: rule)
    }

    private func option(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                        .fontWeight(.semibold)
                }
            }
            .contentShape(.rect)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct WeekdayPicker: View {
    @Binding var selection: [Int]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(RepeatRule.orderedWeekdays, id: \.self) { weekday in
                let isSelected = selection.contains(weekday)

                Button {
                    toggle(weekday)
                } label: {
                    Text(Calendar.current.veryShortWeekdaySymbols[weekday - 1])
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .foregroundStyle(isSelected ? .white : .primary)
                        .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.15), in: .circle)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Calendar.current.weekdaySymbols[weekday - 1])
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(.vertical, 4)
    }

    private func toggle(_ weekday: Int) {
        if let index = selection.firstIndex(of: weekday) {
            guard selection.count > 1 else { return }
            selection.remove(at: index)
        } else {
            selection.append(weekday)
        }
    }
}

#Preview {
    @Previewable @State var rule: RepeatRule? = .everyTwoWeeks
    NavigationStack {
        RepeatPickerView(rule: $rule)
    }
}
