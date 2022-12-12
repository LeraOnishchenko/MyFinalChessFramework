//
//  Board.swift
//  MyFinalChessFramework
//
//  Created by lera on 12.12.2022.
//

public struct Board: Equatable {
    private(set) var pieces: [[Piece?]]
}

public extension Board {
    static let allPositions = (0 ..< 8).flatMap { y in
        (0 ..< 8).map { Position(x: $0, y: y) }
    }

    var allPositions: [Position] { return Self.allPositions }

    var allPieces: [(position: Position, piece: Piece)] {
        return allPositions.compactMap { position in
            pieces[position.y][position.x].map { (position, $0) }
        }
    }

    init() {
        pieces = [
            ["BR0", "BN1", "BB2", "BQ3", "BK4", "BB5", "BN6", "BR7"],
            ["BP0", "BP1", "BP2", "BP3", "BP4", "BP5", "BP6", "BP7"],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil],
            ["WP0", "WP1", "WP2", "WP3", "WP4", "WP5", "WP6", "WP7"],
            ["WR0", "WN1", "WB2", "WQ3", "WK4", "WB5", "WN6", "WR7"],
        ]
    }

    func piece(at position: Position) -> Piece? {
        guard (0 ..< 8).contains(position.y), (0 ..< 8).contains(position.x) else {
            return nil
        }
        return pieces[position.y][position.x]
    }

    func firstPosition(where condition: (Piece) -> Bool) -> Position? {
        return allPieces.first(where: { condition($1) })?.position
    }

    mutating func movePiece(from: Position, to: Position) {
        var pieces = self.pieces
        pieces[to.y][to.x] = piece(at: from)
        pieces[from.y][from.x] = nil
        self.pieces = pieces
    }

    mutating func removePiece(at position: Position) {
        var pieces = self.pieces
        pieces[position.y][position.x] = nil
        self.pieces = pieces
    }

    mutating func promotePiece(at position: Position, to type: PieceType) {
        var piece = self.piece(at: position)
        piece?.type = type
        pieces[position.y][position.x] = piece
    }
}
