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
            .fill(game.get(x: x, y: y) ? Color("on") : Color("off"))
            .border(Color.black, width: 0.3)
            .aspectRatio(1, contentMode: .fit)
            .onTapGesture {
                game.toggle(x: x, y: y)
                print("Hello")
            }
    }
}

#Preview {
    GameView(game: getMockGame(border: false))
}

