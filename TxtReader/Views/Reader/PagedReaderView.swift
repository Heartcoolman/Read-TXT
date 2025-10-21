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
                    // 性能优化：只渲染当前页和相邻页
                    // Current page
                    pageContent(viewModel.pages[viewModel.currentPageIndex])
                        .offset(x: dragOffset)
                        .zIndex(1)
                    
                    // Previous page (if exists) - 懒加载
                    if viewModel.currentPageIndex > 0 && abs(dragOffset) > 10 {
                        pageContent(viewModel.pages[viewModel.currentPageIndex - 1])
                            .offset(x: dragOffset - geometry.size.width)
                            .zIndex(0)
                    }
                    
                    // Next page (if exists) - 懒加载
                    if viewModel.currentPageIndex < viewModel.pages.count - 1 && abs(dragOffset) > 10 {
                        pageContent(viewModel.pages[viewModel.currentPageIndex + 1])
                            .offset(x: dragOffset + geometry.size.width)
                            .zIndex(0)
                    }
                } else {
                    ProgressView("正在加载...")
                        .foregroundColor(settings.currentTheme.textColor)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 20)
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        // 限制拖动范围，提升性能
                        dragOffset = min(max(value.translation.width, -geometry.size.width), geometry.size.width)
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width / 3
                        let velocity = value.predictedEndTranslation.width - value.translation.width
                        
                        // 使用更快的动画
                        withAnimation(.easeOut(duration: 0.25)) {
                            if value.translation.width > threshold || velocity > 500 {
                                // Swipe right - previous page
                                viewModel.previousPage()
                            } else if value.translation.width < -threshold || velocity < -500 {
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
        .id(page.id) // 帮助 SwiftUI 识别页面变化，减少重绘
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

