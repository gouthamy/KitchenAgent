//
//  TestView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Kitchen Agent")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("App is loading...")
                .foregroundColor(.secondary)

            ProgressView()
                .padding()

            Text("If you see this, the app is working!")
                .font(.caption)
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    TestView()
}
