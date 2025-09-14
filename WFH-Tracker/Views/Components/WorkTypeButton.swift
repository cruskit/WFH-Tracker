import SwiftUI

struct WorkTypeButton: View {
    let workType: WorkType
    let isSelected: Bool
    let isActive: Bool
    let onTapped: () -> Void

    var body: some View {
        Button(action: onTapped) {
            VStack(spacing: 4) {
                Text(workType.icon)
                    .font(.system(size: 24))

                Text(workType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
            .foregroundStyle(textColor)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(workType.displayName) work type")
        .accessibilityHint(isSelected ? "Currently selected" : "Tap to select this work type")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var backgroundColor: Color {
        if isSelected {
            return workType.backgroundColor
        } else if isActive {
            return workType.backgroundColor.opacity(0.5)
        } else {
            return Color(.systemGray6)
        }
    }

    private var borderColor: Color {
        if isSelected {
            return workType.color
        } else if isActive {
            return workType.color.opacity(0.5)
        } else {
            return Color.clear
        }
    }

    private var borderWidth: CGFloat {
        isSelected ? 2 : (isActive ? 1 : 0)
    }

    private var textColor: Color {
        if isSelected || isActive {
            return workType.color
        } else {
            return .secondary
        }
    }
}

struct CompactWorkTypeButton: View {
    let workType: WorkType
    let isSelected: Bool
    let isActive: Bool
    let onTapped: () -> Void

    var body: some View {
        Button(action: onTapped) {
            Text(workType.icon)
                .font(.system(size: 18))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(borderColor, lineWidth: borderWidth)
                        )
                )
                .foregroundStyle(textColor)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(workType.displayName) work type")
        .accessibilityHint(isSelected ? "Currently selected" : "Tap to select this work type")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var backgroundColor: Color {
        if isSelected {
            return workType.backgroundColor
        } else if isActive {
            return workType.backgroundColor.opacity(0.5)
        } else {
            return Color(.systemGray6)
        }
    }

    private var borderColor: Color {
        if isSelected {
            return workType.color
        } else if isActive {
            return workType.color.opacity(0.5)
        } else {
            return Color.clear
        }
    }

    private var borderWidth: CGFloat {
        isSelected ? 2 : (isActive ? 1 : 0)
    }

    private var textColor: Color {
        if isSelected || isActive {
            return workType.color
        } else {
            return .secondary
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            ForEach(WorkType.allCases, id: \.self) { workType in
                WorkTypeButton(
                    workType: workType,
                    isSelected: workType == .home,
                    isActive: workType == .office,
                    onTapped: {}
                )
            }
        }

        HStack(spacing: 6) {
            ForEach(WorkType.allCases, id: \.self) { workType in
                CompactWorkTypeButton(
                    workType: workType,
                    isSelected: workType == .home,
                    isActive: workType == .office,
                    onTapped: {}
                )
            }
        }
    }
    .padding()
}