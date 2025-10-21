import SwiftUI

struct ScrollReaderView: View {
    @ObservedObject var viewModel: ReaderViewModel
    @ObservedObject var settings: ReaderSettings
    @Binding var showingMenu: Bool
    
    var body: some View {
        ScrollView {
            Text(viewModel.fullText)
                .font(.custom(settings.fontName, size: settings.fontSize))
                .foregroundColor(settings.currentTheme.textColor)
                .lineSpacing(settings.lineSpacing)
                .padding(.horizontal, settings.horizontalPadding)
                .padding(.vertical, settings.verticalPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onTapGesture {
            withAnimation {
                showingMenu.toggle()
            }
        }
    }
}

