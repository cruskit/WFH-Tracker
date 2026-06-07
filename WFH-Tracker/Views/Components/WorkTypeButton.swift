import SwiftUI

// MARK: - Full-size work type button (used in advanced entry)

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
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(isSelected ? workType.inkColor : .breezeInkMuted)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(isSelected ? workType.softColor : Color.breezeSurfaceSoft)
                    .overlay(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .strokeBorder(
                                isSelected ? workType.color : Color.breezeLine,
                                lineWidth: isSelected ? 1.5 : 1.5
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.04 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(workType.displayName) work type")
        .accessibilityHint(isSelected ? "Currently selected" : "Tap to select")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Compact work-type button used in weekly entry rows

struct CompactWorkTypeButton: View {
    let workType: WorkType
    let isSelected: Bool
    let isActive: Bool
    let onTapped: () -> Void

    var body: some View {
        Button(action: onTapped) {
            ZStack(alignment: .bottom) {
                Text(workType.icon)
                    .font(.system(size: 19))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if isSelected {
                    Text("8h")
                        .font(.breezeDisplay(9))
                        .foregroundStyle(workType.inkColor)
                        .padding(.bottom, 3)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(isSelected ? workType.softColor : Color.breezeSurfaceSoft)
                    .overlay(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .strokeBorder(
                                isSelected ? workType.color : Color.breezeLine,
                                lineWidth: 1.5
                            )
                    )
            )
            .shadow(
                color: isSelected ? workType.color.opacity(0.25) : .clear,
                radius: 4, x: 0, y: 2
            )
            .scaleEffect(isSelected ? 1.06 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(workType.displayName)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 10) {
            ForEach(WorkType.allCases, id: \.self) { wt in
                WorkTypeButton(workType: wt, isSelected: wt == .home, isActive: false, onTapped: {})
            }
        }
        HStack(spacing: 7) {
            ForEach(WorkType.allCases, id: \.self) { wt in
                CompactWorkTypeButton(workType: wt, isSelected: wt == .office, isActive: false, onTapped: {})
            }
        }
    }
    .padding()
    .background(Color.breezeBackground)
}
