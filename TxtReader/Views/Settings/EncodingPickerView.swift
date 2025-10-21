import SwiftUI

struct EncodingPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ReaderViewModel
    @State private var selectedEncoding: String.Encoding = .utf8
    @State private var previewText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Preview
                VStack(alignment: .leading, spacing: 8) {
                    Text("预览")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        Text(previewText)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 200)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                // Encoding list
                List {
                    ForEach(EncodingDetector.supportedEncodings, id: \.1) { encoding, name in
                        Button(action: {
                            selectedEncoding = encoding
                            updatePreview(encoding: encoding)
                        }) {
                            HStack {
                                Text(name)
                                Spacer()
                                if encoding == selectedEncoding {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择编码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
                        applyEncoding()
                    }
                }
            }
            .onAppear {
                updatePreview(encoding: selectedEncoding)
            }
        }
    }
    
    private func updatePreview(encoding: String.Encoding) {
        do {
            let fileURL = URL(fileURLWithPath: viewModel.book.filePath)
            let data = try Data(contentsOf: fileURL)
            let sampleData = data.prefix(1000)
            
            previewText = EncodingDetector.previewText(data: sampleData, encoding: encoding, lines: 5)
        } catch {
            previewText = "无法加载预览"
        }
    }
    
    private func applyEncoding() {
        let encodingName = EncodingDetector.supportedEncodings.first { $0.0 == selectedEncoding }?.1 ?? "UTF-8"
        
        Task {
            await viewModel.changeEncoding(selectedEncoding, encodingName: encodingName)
            dismiss()
        }
    }
}

