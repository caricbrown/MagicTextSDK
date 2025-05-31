//
//  ContentView.swift
//  DemoApp
//
//  Created by Aric on 5/31/25.
//

import SwiftUI
import MagicTextSDK

struct ContentView: View {
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            Text("Magic 8-Ball Demo")
                .font(.largeTitle)
                .padding(.top, 40)
                .padding(.bottom, 10)

            MagicTextView(
                config: .init(
                    webURL: URL(string: "https://emej3lexpx.appflowapp.com/chat")!
                ),
                onLoad: {
                    print("✅ Web content finished loading.")
                },
                onError: { error in
                    errorMessage = error.localizedDescription
                    showError = true
                }
            )
            .edgesIgnoringSafeArea(.bottom)

            if showError {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
