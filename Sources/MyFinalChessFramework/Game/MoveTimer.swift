//
//  MoveTimer.swift
//  MyFinalChessFramework
//
//  Created by lera on 12.12.2022.
//

public enum MoveTimer: Int {
    case tenSeconds = 10
    case fifteen = 15
    case minute = 60
    case infinity = -1
    
    var time: Int{
        switch self{
        case .tenSeconds:
            return 10_000
        case .fifteen:
            return 15_000
        case .minute:
            return 60_000
        case .infinity:
            return -1
        }
    }
}
