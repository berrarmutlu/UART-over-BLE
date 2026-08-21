//
//  SplashView.swift
//  UART over BLE
//
//  Created by Berra Armutlu on 21.08.2026.
//

import SwiftUI

struct SplashView: View {
    @State private var isFinished = false
    
    var body: some View {
        Group {
            if isFinished {
                ContentView()
            } else {
                VStack(spacing: 16) {
                    Image("PCSLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)

                    Text("PCS Elektronik")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text("Mühendislik ve Danışmanlık")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .offset(y: -40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isFinished = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
