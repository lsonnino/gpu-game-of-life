//
//  Game.swift
//  GameOfLife
//
//  Created by Lorenzo Sonnino on 04/05/2024.
//

import Foundation
import simd


class Game: ObservableObject {
    let size: Int
    @Published var border: Bool
    @Published var state: [[Int]]
    @Published var useSuper: Bool
    
    init(_ size: Int, border: Bool = true, useSuper: Bool = false) {
        self.size = size
        self.border = border
        self.state = Game.getEmptyArray(size)
        self.useSuper = useSuper
    }
    
    func reset() {
        self.state = Game.getEmptyArray(size)
    }
    
    func isInBounds(x: Int, y: Int) -> Bool {
        return ((0 <= x) && (x < size) && (0 <= y) && (y < size))
    }
    
    func get(x: Int, y: Int) -> Int {
        if (isInBounds(x: x, y: y)) {
            return state[y][x]
        }
        else {
            return border ? 1 : 0
        }
    }
    
    func set(x: Int, y: Int, value: Int) {
        if (isInBounds(x: x, y: y)) {
            state[y][x] = value
        }
    }
    
    func toggle(x: Int, y: Int) {
        let value = get(x: x, y: y)
        set(x: x, y: y, value: value > 0 ? 0 : 1)
    }
    
    func setBorder(value: Bool) {
        self.border = value
    }
    func setSuper(value: Bool) {
        self.useSuper = value
    }
    
    static func getEmptyArray(_ size: Int) -> [[Int]] {
        return Array(repeating: 0, count: size * size).unflatten(dim: size)
    }
}

// From: https://forums.swift.org/t/ways-of-creating-2-dimensional-array-in-swift/36595
extension Array {
    func unflatten(dim: Int) -> [[Element]] {
        let hasRemainder = !count.isMultiple(of: dim)
        
        var result = [[Element]]()
        let size = count / dim
        result.reserveCapacity(size + (hasRemainder ? 1 : 0))
        for i in 0..<size {
            result.append(Array(self[i*dim..<(i + 1) * dim]))
        }
        if hasRemainder {
            result.append(Array(self[(size * dim)...]))
        }
        return result
    }
}

func getMockGame(border: Bool = false) -> Game {
    let size = 8
    let game = Game(size, border: border)
    
    game.set(x: 1, y: 1, value: 1)
    game.set(x: 2, y: 1, value: 1)
    game.set(x: 2, y: 2, value: 1)
    
    game.set(x: 3, y: 5, value: 1)
    game.set(x: 4, y: 5, value: 1)
    game.set(x: 5, y: 5, value: 1)
    game.set(x: 6, y: 5, value: 1)
    
    return game
}
