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
    
    let customJS = """
        // Run when the DOM is fully loaded
        window.addEventListener('load', function() {
          document.querySelectorAll('ion-button.in-toolbar').forEach(function(btn) {
            btn.style.setProperty('--background', '#ff4080', 'important');
            btn.style.setProperty('--color', '#ffffff', 'important');
            btn.style.setProperty('--border-radius', '8px', 'important');
            btn.style.setProperty('--padding-top', '10px', 'important');
            btn.style.setProperty('--padding-bottom', '10px', 'important');
            btn.style.setProperty('--padding-start', '20px', 'important');
            btn.style.setProperty('--padding-end', '20px', 'important');
            btn.style.setProperty('--font-weight', 'bold', 'important');
          });
        });
    """
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Magic 8-Ball Demo")
                .font(.largeTitle)
                .padding(.top, 40)
                .padding(.bottom, 10)
            
            MagicTextView(
                config: .init(
                    webURL: URL(string: "https://emej3lexpx.appflowapp.com/chat")!,
                    backgroundColor: .clear,
                    customJS: customJS
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
