//
//  GameLogic.swift
//  MyFinalChessFramework
//
//  Created by lera on 12.12.2022.
//

public struct Game {
    private(set) var rollbackOffset: Int
    private(set) var gameTimer: GameTimer
    private(set) var moveTimer: MoveTimer
    private(set) var board: Board
    private(set) var log: [MoveResult]
    private(set) var winner: Color?
}

public extension Game {
    
    init(gameTimerSetting: TimerSeting, moveTimerSetting: MoveTimer) {
        board = Board()
        gameTimer = GameTimer(initialTime: gameTimerSetting)
        moveTimer = moveTimerSetting
        log = []
        rollbackOffset = 0
    }
    
    mutating func reset() -> Game {
        self = Game(gameTimerSetting: gameTimer.initialTime, moveTimerSetting: moveTimer)
        return self
    }
    
    var turn: Color {
        return log.last.flatMap {
            $0.player?.other
        } ?? .white
    }
    
    var state: GameState {
        let color = turn
        let canMove = allMoves(for: color).contains(where: { move in
            var newBoard = self
            newBoard.board.movePiece(from: move.from, to: move.to)
            return !newBoard.kingIsInCheck(for: color)
        })
        if kingIsInCheck(for: color) {
            return canMove ? .check : .checkMate
        }
        return canMove ? .idle : .staleMate
    }
    
    var enemyState: GameState {
        let color = turn.other
        let canMove = allMoves(for: color).contains(where: { move in
            var newBoard = self
            newBoard.board.movePiece(from: move.from, to: move.to)
            return !newBoard.kingIsInCheck(for: color)
        })
        if kingIsInCheck(for: color) {
            return canMove ? .check : .checkMate
        }
        return canMove ? .idle : .staleMate
    }
    
    
    
    // MARK: Game logic
    
    mutating func updateGameTimer(color: Color, spentTime: Int){
        switch turn {
        case .black:
            if gameTimer.blackPlayerRemainingTimeMillis == nil{
                return
            }
            gameTimer.blackPlayerRemainingTimeMillis! -= spentTime
            if (gameTimer.blackPlayerRemainingTimeMillis! <= 0) {
                winner = .white
            }
        case .white:
            if gameTimer.whitePlayerRemainingTimeMillis == nil{
                return
            }
            gameTimer.whitePlayerRemainingTimeMillis! -= spentTime
            if (gameTimer.whitePlayerRemainingTimeMillis! <= 0) {
                winner = .black
            }
        }
    }
    
    func canSelectPiece(at position: Position) -> Bool {
        return board.piece(at: position)?.color == turn
    }
    
     mutating func makeMove(_ move: Move)-> MoveResult  {
        if(winner != nil){
            return MoveResult(isPossible: false)
        }
        if(move.spentTime > moveTimer.time && moveTimer.time != -1){
            winner = turn.other
            return MoveResult(isPossible: false, state: .resigned)
        }
        let initialTimer = log.last?.remainingTime ?? gameTimer.initialTime.timer
        if !canMove(from: move.from, to: move.to){
            let moveResult = MoveResult(isPossible: false)
            return moveResult
        }
        let position = move.to
        let oldGame = self
        self.move(from: move.from, to: position)
        let kingPosition = self.kingPosition(for: oldGame.turn)
        let wasInCheck = self.pieceIsThreatened(at: kingPosition)
        let wasPromoted = !wasInCheck && self.canPromotePiece(at: position)
        if wasInCheck {
            self = oldGame
            let moveResult = MoveResult(isPossible: false)
            return moveResult
        }
        updateGameTimer(color: turn, spentTime: move.spentTime)
        if wasPromoted {
            let moveResult = MoveResult(isPromotion: true, isPossible: true, player: turn, initialTime: initialTimer,remainingTime: initialTimer - move.spentTime)
            log.append(moveResult)
            return moveResult
        }
        let enemyState = self.enemyState
        let moveResult = MoveResult(isPromotion: false, isPossible: true,player: turn, initialTime: initialTimer,remainingTime: initialTimer - move.spentTime,state: enemyState)
        if self.enemyState == .checkMate{
            winner = turn
        }
        log.append(moveResult)
        return moveResult
    }
    
    func canMove(from: Position, to: Position) -> Bool {
        guard let this = board.piece(at: from) else {
            return false
        }
        let delta = to - from
        if let other = board.piece(at: to) {
            guard other.color != this.color else {
                return false
            }
            if this.type == .pawn {
                return pawnCanTake(from: from, with: delta)
            }
        }
        switch this.type {
        case .pawn:
            if enPassantTakePermitted(from: from, to: to) {
                return true
            }
            if delta.x != 0 {
                return false
            }
            switch this.color {
            case .white:
                if from.y == 6 {
                    return [-1, -2].contains(delta.y) &&
                    !board.piecesExist(between: from, and: to)
                }
                return delta.y == -1
            case .black:
                if from.y == 1 {
                    return [1, 2].contains(delta.y) &&
                    !board.piecesExist(between: from, and: to)
                }
                return delta.y == 1
            }
        case .rook:
            return (delta.x == 0 || delta.y == 0) &&
            !board.piecesExist(between: from, and: to)
        case .bishop:
            return abs(delta.x) == abs(delta.y) &&
            !board.piecesExist(between: from, and: to)
        case .queen:
            return (delta.x == 0 || delta.y == 0 || abs(delta.x) == abs(delta.y)) &&
            !board.piecesExist(between: from, and: to)
        case .king:
            if abs(delta.x) <= 1, abs(delta.y) <= 1 {
                return true
            }
            return castlingPermitted(from: from, to: to)
        case .knight:
            return [
                Delta(x: 1, y: 2),
                Delta(x: -1, y: 2),
                Delta(x: 2, y: 1),
                Delta(x: -2, y: 1),
                Delta(x: 1, y: -2),
                Delta(x: -1, y: -2),
                Delta(x: 2, y: -1),
                Delta(x: -2, y: -1),
            ].contains(delta)
        }
    }
    
    func pieceIsThreatened(at position: Position) -> Bool {
        return board.allPositions.contains(where: { canMove(from: $0, to: position) })
    }
    
    func positionIsThreatened(_ position: Position, by color: Color) -> Bool {
        return board.allPieces.contains(where: { from, piece in
            guard piece.color == color else {
                return false
            }
            if piece.type == .pawn {
                return pawnCanTake(from: from, with: position - from)
            }
            return canMove(from: from, to: position)
        })
    }
    
    func kingPosition(for color: Color) -> Position {
        board.firstPosition(where: {
            $0.type == .king && $0.color == color
        }) ?? .init(x: 0, y: 0)
    }
    
    func kingIsInCheck(for color: Color) -> Bool {
        pieceIsThreatened(at: kingPosition(for: color))
    }
    
    mutating func move(from: Position, to: Position) {
        assert(canMove(from: from, to: to))
        switch board.piece(at: from)?.type {
        case .pawn where enPassantTakePermitted(from: from, to: to):
            board.removePiece(at: Position(x: to.x, y: to.y - (to.y - from.y)))
        case .king where abs(to.x - from.x) > 1:
            let kingSide = (to.x == 6)
            let rookPosition = Position(x: kingSide ? 7 : 0, y: to.y)
            let rookDestination = Position(x: kingSide ? 5 : 3, y: to.y)
            board.movePiece(from: rookPosition, to: rookDestination)
        default:
            break
        }
        board.movePiece(from: from, to: to)
    }
    
    func canPromotePiece(at position: Position) -> Bool {
        if let pawn = board.piece(at: position), pawn.type == .pawn,
           (pawn.color == .white && position.y == 0) ||
            (pawn.color == .black && position.y == 7) {
            return true
        }
        return false
    }
    
    mutating func promotePiece(at position: Position, to type: PieceType) -> MoveResult {
        if canPromotePiece(at: position){
            board.promotePiece(at: position, to: type)
            var currMoveResult = log.last
            currMoveResult?.state = self.state
            currMoveResult?.board = self.board
            log.insert(currMoveResult!, at: log.endIndex-1)
            if self.enemyState == .checkMate{
                winner = turn
            }
            return currMoveResult!
        }
        return log.last ?? MoveResult(isPossible: false)
    }
    
    func movesForPiece(at position: Position) -> [Position] {
        return board.allPositions.filter { canMove(from: position, to: $0) }
    }
    
    mutating func resign(player: Color) -> MoveResult {
        winner = turn.other
        return MoveResult(isPossible: true, board: board, player: player, state: .resigned)
    }
    
    mutating func rollBackAction() -> Board? {
        if state == .idle || state == .check{
            return nil
        }
        if log.count - rollbackOffset == 0{
            return nil
        }
        else if log.count - rollbackOffset == 1 {
            self.board = Board()
            return self.board
        }
        let lastIndex = log.endIndex-2 - rollbackOffset
        self.board = log[lastIndex].board!
        self.rollbackOffset += 1
        return self.board
    }
    
    mutating func rollForwardAction() -> Board? {
        if rollbackOffset == 0{
            return nil
        }
        let nextIndex = log.endIndex - rollbackOffset
        self.board = log[nextIndex].board!
        self.rollbackOffset -= 1
        return self.board
    }
    
    
    
}

private extension Game {
    func allMoves(for color: Color) ->
        LazySequence<FlattenSequence<LazyMapSequence<[Position], LazyFilterSequence<[Move]>>>> {
        return board.allPieces
            .compactMap { $1.color == color ? $0 : nil }
            .lazy.flatMap { self.allMoves(for: $0) }
    }

    func allMoves(for position: Position) -> LazyFilterSequence<[Move]> {
        return board.allPositions
            .map { Move(from: position, to: $0, spentTime: 0) }
            .lazy.filter { self.canMove(from: $0.from, to: $0.to) }
    }

    func allThreats(for color: Color) -> LazyFilterSequence<[(position: Position, piece: Piece)]> {
        return board.allPieces.lazy.filter { position, piece in
            return piece.color == color && self.pieceIsThreatened(at: position)
        }
    }

    func pawnCanTake(from: Position, with delta: Delta) -> Bool {
        guard abs(delta.x) == 1, let pawn = board.piece(at: from) else {
            return false
        }
        assert(pawn.type == .pawn)
        switch pawn.color {
        case .white:
            return delta.y == -1
        case .black:
            return delta.y == 1
        }
    }

    func enPassantTakePermitted(from: Position, to: Position) -> Bool {
        guard let this = board.piece(at: from),
            pawnCanTake(from: from, with: to - from),
              let lastMove = log.last?.move, lastMove.to.x == to.x,
            let piece = board.piece(at: lastMove.to),
            piece.type == .pawn, piece.color != this.color
        else {
            return false
        }
        switch piece.color {
        case .white:
            return lastMove.from.y == to.y + 1 && lastMove.to.y == to.y - 1
        default:
            return lastMove.from.y == to.y - 1 && lastMove.to.y == to.y + 1
        }
    }

    func pieceHasMoved(at position: Position) -> Bool {
        return log.contains(where: { $0.move?.from == position })
    }
    
   

    func castlingPermitted(from: Position, to: Position) -> Bool {
        guard let this = board.piece(at: from) else {
            return false
        }
        assert(this.type == .king)
        let kingsRow = this.color == .black ? 0 : 7
        guard from.y == kingsRow, to.y == kingsRow,
            from.x == 4, [2, 6].contains(to.x) else {
            return false
        }
        let kingPosition = Position(x: 4, y: kingsRow)
        if pieceHasMoved(at: kingPosition) {
            return false
        }
        let isKingSide = (to.x == 6)
        let rookPosition = Position(x: isKingSide ? 7 : 0, y: kingsRow)
        if pieceHasMoved(at: rookPosition) {
            return false
        }
        return !(isKingSide ? 5 ... 6 : 1 ... 3).contains(where: {
            board.piece(at: Position(x: $0, y: kingsRow)) != nil
        }) && !(isKingSide ? 4 ... 6 : 2 ... 4).contains(where: {
            positionIsThreatened(Position(x: $0, y: kingsRow), by: this.color.other)
        })
    }
}

private extension Board {
    func piecesExist(between: Position, and: Position) -> Bool {
        let step = Delta(
            x: between.x > and.x ? -1 : (between.x < and.x ? 1 : 0),
            y: between.y > and.y ? -1 : (between.y < and.y ? 1 : 0)
        )
        var position = between
        position += step
        while position != and {
            if piece(at: position) != nil {
                return true
            }
            position += step
        }
        return false
    }
}

