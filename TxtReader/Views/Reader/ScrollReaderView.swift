import SwiftUI

struct ScrollReaderView: View {
    @ObservedObject var viewModel: ReaderViewModel
    @ObservedObject var settings: ReaderSettings
    @Binding var showingMenu: Bool
    
    var body: some View {
        ScrollView {
            // 使用 LazyVStack 提升大文本滚动性能
            LazyVStack(alignment: .leading, spacing: settings.paragraphSpacing) {
                // 按段落分割文本，避免一次性渲染
                ForEach(paragraphs, id: \.self) { paragraph in
                    Text(paragraph)
                        .font(.custom(settings.fontName, size: settings.fontSize))
                        .foregroundColor(settings.currentTheme.textColor)
                        .lineSpacing(settings.lineSpacing)
                }
            }
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
    
    // 将文本分割为段落，提升渲染性能
    private var paragraphs: [String] {
        viewModel.fullText
            .components(separatedBy: "\n\n")
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
}

