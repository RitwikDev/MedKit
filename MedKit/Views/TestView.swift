import SwiftUI

struct MultiAutocompleteView: View {
    @State private var text = ""

        let suggestions = [
            "Apple",
            "Banana",
            "Orange",
            "Grapes",
            "Mango",
            "Pineapple",
            "Strawberry"
        ]

        var filteredSuggestions: [String] {
            if text.isEmpty {
                return suggestions
            }

            return suggestions.filter {
                $0.localizedCaseInsensitiveContains(text)
            }
        }

        var body: some View {

            VStack {

                TextField("Search fruit", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                if filteredSuggestions.isEmpty {
                    Button("Create \(text)") {
                        
                    }
                } else {

                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {

                            ForEach(filteredSuggestions, id: \.self) { suggestion in

                                Button {
                                    text = suggestion
                                } label: {

                                    HStack {
                                        Text(suggestion)
                                            .foregroundColor(.primary)

                                        Spacer()
                                    }
                                    .padding()
                                }

                                Divider()
                            }
                        }
                        .background(Color(.systemBackground))
                    }
                    .padding(.horizontal)
                }
            }
        }
}

#Preview {
    MultiAutocompleteView()
}
