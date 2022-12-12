//
//  Position.swift
//  MyFinalChessFramework
//
//  Created by lera on 12.12.2022.
//

public struct Position: Hashable {
    public var x, y: Int

    public static func - (lhs: Position, rhs: Position) -> Delta {
        return Delta(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func + (lhs: Position, rhs: Delta) -> Position {
        return Position(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func += (lhs: inout Position, rhs: Delta) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
}
