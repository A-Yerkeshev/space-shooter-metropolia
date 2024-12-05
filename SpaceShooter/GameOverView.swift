//
//  GameOverView.swift
//  SpaceShooter
//
//  Created by Anna Lindén on 5.12.2024.
//
import SwiftUI

struct GameOverView: View {
    var score: Int
    var onSubmit: (String) -> Void
    @State private var playerName: String = ""

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Game Over")
                    .font(.custom("Chalkduster", size: 60))
                    .foregroundColor(.red)
                    .padding(.top, 50)
                
                Text("Your Score: \(score)")
                    .font(.custom("Chalkduster", size: 40))
                    .foregroundColor(.white)
                
                TextField("Enter your name", text: $playerName)
                    .font(.custom("Chalkduster", size: 25))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 50)
                
                Button(action: {
                    onSubmit(playerName.isEmpty ? "Anonymous" : playerName)
                }) {
                    Text("Submit")
                        .font(.custom("Chalkduster", size: 30))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.bottom, 50)
            }
            .background(Color.black.opacity(0.9))
            .cornerRadius(20)
            .padding()
        }
    }
}


