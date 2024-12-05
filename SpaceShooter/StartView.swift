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
                    NavigationLink {
                        ContentView()
                            .navigationBarHidden(true)
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Text("Start Game")
                            .font(.custom("Chalkduster", size: 30))
                            .foregroundColor(.white)
                            .padding(.top, 40)
                        
                    }
                    
                    NavigationLink {
                        LeaderboardView()
                    } label: {
                        Text("Leaderboard")
                            .font(.custom("Chalkduster", size: 30))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                    }

                    
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
                    
                }
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
