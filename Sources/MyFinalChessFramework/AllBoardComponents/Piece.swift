//
//  Piece.swift
//  MyFinalChessFramework
//
//  Created by lera on 12.12.2022.
//

public struct Piece: Equatable, ExpressibleByStringLiteral {
    public let id: String
    public var type: PieceType
    public let color: Color

    public init(stringLiteral: String) {
        id = stringLiteral
        let chars = Array(stringLiteral)
        precondition(chars.count == 3)
        switch chars[0] {
        case "B": color = .black
        case "W": color = .white
        default:
            preconditionFailure()
        }
        switch chars[1] {
        case "P": type = .pawn
        case "R": type = .rook
        case "N": type = .knight
        case "B": type = .bishop
        case "Q": type = .queen
        case "K": type = .king
        default:
            preconditionFailure()
        }
    }
}
