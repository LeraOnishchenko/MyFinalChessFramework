//
//  MoveResult.swift
//  MyFinalChessFramework
//
//  Created by lera on 12.12.2022.
//
public struct MoveResult {
    public var isPromotion: Bool?
    public var isPossible: Bool
    public var board: Board?
    public var move: Move?
    public var player: Color?
    public var initialTime: Int?
    public var remainingTime: Int?
    public var state: GameState?
}
