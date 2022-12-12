//
//  Color.swift
//  MyFinalChessFramework
//
//  Created by lera on 12.12.2022.
//

 public enum Color: String {
    case white
    case black

    var other: Color {
        return self == .black ? .white : .black
    }
}
