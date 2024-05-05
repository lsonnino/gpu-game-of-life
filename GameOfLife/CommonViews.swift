//
//  CommonViews.swift
//  GameOfLife
//
//  Created by Lorenzo Sonnino on 05/05/2024.
//

import Foundation
import SwiftUI

extension View {
    func glow(color: Color = .white, radius: CGFloat = 20) -> some View {
        self
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            //.shadow(color: color, radius: radius / 3)
    }
}

struct MainButtonStyle: ButtonStyle {
    let isToggleButton: Bool
    @Binding var toggled: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        if isToggleButton {
            configuration.label
                .foregroundColor(toggled ? Color.off : Color.on)
                .background(toggled ? Color.on : Color.off)
                .cornerRadius(0.0)
        }
        else {
            configuration.label
                .foregroundColor(configuration.isPressed ? Color.off : Color.on)
                .background(configuration.isPressed ? Color.on : Color.off)
                .cornerRadius(0.0)
        }
    }
}

struct MainButton: View {
    let text: String
    let width: CGFloat
    var toggleButton: Bool = false
    var toggleText: String = ""
    var action: (Bool) -> Void
    
    @State var toggled: Bool = false
    
    var body: some View {
        Button(action: {
            if toggleButton {
                toggled.toggle()
            }
            
            action(toggled)
        }) {
            Text(toggleButton && toggled ? toggleText : text)
                .frame(width: width, height: 50)
        }
        .buttonStyle(MainButtonStyle(isToggleButton: toggleButton, toggled: $toggled))
    }
}
