import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ReaderViewModel
    @ObservedObject var settings: ReaderSettings
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("搜索...", text: $searchText)
                        .textFieldStyle(.plain)
                        .onChange(of: searchText) { _, newValue in
                            viewModel.search(query: newValue)
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            viewModel.searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(10)
                .padding()
                
                // Results
                if viewModel.isSearching {
                    ProgressView()
                        .padding()
                } else if searchText.isEmpty {
                    Text("输入关键词搜索")
                        .foregroundColor(.secondary)
                        .frame(maxHeight: .infinity)
                } else if viewModel.searchResults.isEmpty {
                    Text("未找到结果")
                        .foregroundColor(.secondary)
                        .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.searchResults) { result in
                            Button(action: {
                                // Jump to position
                                if !viewModel.pages.isEmpty {
                                    let pageIndex = PaginationEngine.findPageIndex(at: result.position, in: viewModel.pages)
                                    viewModel.goToPage(pageIndex)
                                }
                                dismiss()
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(result.chapterTitle)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    
                                    Text(result.excerpt)
                                        .font(.body)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.plain)
                    
                    Text("找到 \(viewModel.searchResults.count) 个结果")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

