//
//  ContentView.swift
//  GameOfLife
//
//  Created by Lorenzo Sonnino on 04/05/2024.
//

import SwiftUI
import SwiftData

private let size: Int = 16

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var gameHandler: GameHandler = GameHandler(size: size, borders: false)

    var body: some View {
        HStack(spacing: 0) {
            ParametersView(gameHandler: gameHandler, width: 200, isBorderOn: gameHandler.game.border)
            
            Divider()
            
            Spacer()
            
            GameView(game: gameHandler.game)
                .padding(20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
        .ignoresSafeArea()
        .onAppear {
            gameHandler.setup()
        }
    }
}

struct ParametersView: View {
    @ObservedObject var gameHandler: GameHandler
    let width: CGFloat
    
    @State var isBorderOn: Bool
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Game of Life")
                .font(.title)
                .bold()
                .foregroundStyle(.text)
            
            Text("by Lorenzo")
                .foregroundStyle(.text)
            
            Spacer()
            
            Toggle(isOn: $isBorderOn) {
                Text(isBorderOn ? "Borders on : " : "Borders off : ")
                    .foregroundStyle(.text)
            }
            .toggleStyle(.switch)
            .onChange(of: isBorderOn, {
                gameHandler.game.setBorder(value: isBorderOn)
                print("Borders changed to \(isBorderOn)")
            })
            
            HStack (spacing: 0) {
                Button(action: {
                    gameHandler.game.reset()
                    print("Game reset")
                }) {
                    Text("Reset")
                        .frame(width: width / 2, height: 50)
                }
                .buttonStyle(MainButtonStyle(isToggleButton: false, toggled: .constant(false)))
                
                Toggle(isOn: $gameHandler.play) {
                    Text(gameHandler.play ? "Stop" : "Play")
                        .frame(width: width / 2, height: 50)
                }
                .toggleStyle(.button)
                .buttonStyle(MainButtonStyle(isToggleButton: true, toggled: $gameHandler.play))
                .onChange(of: gameHandler.play, {
                    if (gameHandler.play) {
                        print("Game resumed")
                    }
                    else {
                        print("Game stopped")
                    }
                })
            }
        }
        .frame(width: width)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
