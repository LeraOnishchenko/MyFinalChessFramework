//
//  PieceType.swift
//  MyFinalChessFramework
//
//  Created by lera on 12.12.2022.
//

 public enum PieceType: String {
    case pawn
    case rook
    case knight
    case bishop
    case queen
    case king

    var value: Int {
        switch self {
        case .pawn:
            return 1
        case .knight, .bishop:
            return 3
        case .rook:
            return 5
        case .queen:
            return 9
        case .king:
            return 0
        }
    }
}
