//
//  StartView.swift
//  SpaceShooter
//
//  Created by Andrii Deshko on 26.11.2024.
//

import SwiftUI
import SpriteKit

var shipChoice = UserDefaults.standard

struct StartView: View {
    @State private var showGameView = false
    @State private var showLeaderboard = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("spaceShooterMenu")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    Text("Space Shooter")
                        .font(.custom("Chalkduster", size: 45))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.0))
                        .padding(.top, 250)
                    
                    Spacer()
                    Button(action: {
                        showGameView = true
                        }) {
                        Text("Start Game")
                                .font(.custom("Chalkduster", size: 30))
                                .foregroundColor(.white)
                    }.padding(10)

                    Button(action: {
                        showLeaderboard = true
                        }) {
                        Text("Leaderboard")
                                    .font(.custom("Chalkduster", size: 30))
                                    .foregroundColor(.white)
                        }.padding(10)

                    
                    Text("Choose your ship")
                        .font(.custom("Chalkduster", size: 20))
                        .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.0))
                        .padding(20)
                    HStack {
                        Button {
                            makePlayerChoice()
                        } label: {
                            Text("Attacker")
                                .font(.custom("Chalkduster", size: 20))
                                .foregroundColor(.white)
                        }
                        .padding(6)
                        
                        Button {
                            makePlayerChoice2()
                        } label: {
                            Text("Destroyer")
                                .font(.custom("Chalkduster", size: 20))
                                .foregroundColor(.white)
                        }
                        .padding(6)
                        
                        Button {
                            makePlayerChoice3()
                        } label: {
                            Text("Defender")
                                .font(.custom("Chalkduster", size: 20))
                                .foregroundColor(.white)
                        }
                        .padding(6)
                    }
                    
                    NavigationLink(destination: LeaderboardView(), isActive: $showLeaderboard) {
                                            EmptyView()
                                        }
                                    }
                                }
                                .fullScreenCover(isPresented: $showGameView) {
                                    ContentView(onGameOver: {
                                        showLeaderboard = true
                                    })
                                    .navigationBarHidden(true)
                                    .navigationBarBackButtonHidden(true)
                                }
                            }
                        }
    
    func makePlayerChoice() {
        shipChoice.set(1, forKey: "playerChoice")
    }
    
    func makePlayerChoice2() {
        shipChoice.set(2, forKey: "playerChoice")
    }
    
    func makePlayerChoice3() {
        shipChoice.set(3, forKey: "playerChoice")
    }
}



#Preview {
    StartView()
}
