//
//  LeaderboardView.swift
//  SpaceShooter
//
//  Created by Anna Lindén on 5.12.2024.
//
import SwiftUI
import SwiftData

struct LeaderboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @Query(sort: \BestScore.score, order: .reverse) var bestScores: [BestScore]
    
    var body: some View {
        ZStack {
            Image("spaceShooterMenu")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(
                    Color.black.opacity(0.4)
                )
            
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Text("Back")
                                .font(.custom("Chalkduster", size: 30))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                .padding(EdgeInsets(top: 20, leading: 25, bottom: 0, trailing: 0))
                
                Text("Leaderboard")
                    .font(.custom("Chalkduster", size: 45))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.0))
                    .padding(.top, 10)
                
                List(bestScores) { score in
                    HStack {
                        Text(score.name)
                            .font(.custom("Chalkduster", size: 20))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(score.score)")
                            .font(.custom("Chalkduster", size: 20))
                            .foregroundColor(.white)
                        Spacer()
                        Text(score.date, format: .dateTime)
                            .font(.custom("Chalkduster", size: 15))
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal, 16)
            }
        }
        .navigationBarHidden(true)
    }
}



