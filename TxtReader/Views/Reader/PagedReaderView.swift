import SwiftUI

struct PagedReaderView: View {
    @ObservedObject var viewModel: ReaderViewModel
    @ObservedObject var settings: ReaderSettings
    @Binding var showingMenu: Bool
    
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !viewModel.pages.isEmpty && viewModel.currentPageIndex < viewModel.pages.count {
                    // Current page
                    pageContent(viewModel.pages[viewModel.currentPageIndex])
                        .offset(x: dragOffset)
                    
                    // Previous page (if exists)
                    if viewModel.currentPageIndex > 0 {
                        pageContent(viewModel.pages[viewModel.currentPageIndex - 1])
                            .offset(x: dragOffset - geometry.size.width)
                    }
                    
                    // Next page (if exists)
                    if viewModel.currentPageIndex < viewModel.pages.count - 1 {
                        pageContent(viewModel.pages[viewModel.currentPageIndex + 1])
                            .offset(x: dragOffset + geometry.size.width)
                    }
                } else {
                    Text("正在加载...")
                        .foregroundColor(settings.currentTheme.textColor)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width / 3
                        
                        withAnimation(.spring()) {
                            if value.translation.width > threshold {
                                // Swipe right - previous page
                                viewModel.previousPage()
                            } else if value.translation.width < -threshold {
                                // Swipe left - next page
                                viewModel.nextPage()
                            }
                            dragOffset = 0
                        }
                    }
            )
            .onTapGesture { location in
                handleTap(at: location, in: geometry.size)
            }
        }
    }
    
    private func pageContent(_ page: Page) -> some View {
        ScrollView {
            Text(page.text)
                .font(.custom(settings.fontName, size: settings.fontSize))
                .foregroundColor(settings.currentTheme.textColor)
                .lineSpacing(settings.lineSpacing)
                .padding(.horizontal, settings.horizontalPadding)
                .padding(.vertical, settings.verticalPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("第 \(page.number) 页")
                .accessibilityValue(page.text)
                .accessibilityAddTraits(.isStaticText)
        }
        .scrollDisabled(true)
    }
    
    private func handleTap(at location: CGPoint, in size: CGSize) {
        let leftZone = size.width * 0.2
        let rightZone = size.width * 0.8
        
        if location.x < leftZone {
            // Left tap - previous page
            withAnimation {
                viewModel.previousPage()
            }
        } else if location.x > rightZone {
            // Right tap - next page
            withAnimation {
                viewModel.nextPage()
            }
        } else {
            // Middle tap - toggle menu
            withAnimation {
                showingMenu.toggle()
            }
        }
    }
}

