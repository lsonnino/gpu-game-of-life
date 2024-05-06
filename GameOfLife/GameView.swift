//
//  GameView.swift
//  GameOfLife
//
//  Created by Lorenzo Sonnino on 04/05/2024.
//

import SwiftUI
import simd

struct GameView: View {
    @ObservedObject var game: Game
    
    var body: some View {
        ZStack {
            Color.black
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .glow(
                    color: game.border ? Color("on") : Color("off"),
                    radius: 20
                )
            
            VStack (spacing: 0) {
                ForEach (0..<game.size, id: \.self) { y in
                    HStack (spacing: 0)  {
                        ForEach (0..<game.size, id: \.self) { x in
                            ElementView(
                                game: game,
                                x: x, y: y
                            )
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct ElementView: View {
    @ObservedObject var game: Game
    let x: Int
    let y: Int
    
    var body: some View {
        Rectangle()
            .fill(getColor(value: game.get(x: x, y: y)))
            .border(Color.black, width: 0.3)
            .aspectRatio(1, contentMode: .fit)
            .onTapGesture {
                game.toggle(x: x, y: y)
            }
    }
    
    func getColor(value: Int) -> Color {
        if value == 1 {
            return Color.on
        }
        else if value == 2 {
            return Color("super")
        }
        else {
            return Color.off
        }
    }
}

#Preview {
    GameView(game: getMockGame(border: false))
}

