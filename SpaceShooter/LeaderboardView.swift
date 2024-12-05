//
//  LeaderboardView.swift
//  SpaceShooter
//
//  Created by Anna Lindén on 5.12.2024.
//
import SwiftUI
import SwiftData

struct LeaderboardView: View {
    @Query(sort: \BestScore.score, order: .reverse) var bestScores: [BestScore]

    var body: some View {
        ZStack {
            // Background Image
            Image("spaceShooterMenu")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Text("Leaderboard")
                    .font(.custom("Chalkduster", size: 45))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 1.0, green: 0.0, blue: 0.0))
                    .padding(.top, 20)

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
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}



