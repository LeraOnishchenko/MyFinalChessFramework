//
//  GameTimer.swift
//  MyFinalChessFramework
//
//  Created by lera on 12.12.2022.
//
public enum TimerSeting: Int{
    
    case ten = 600_000
    case thirty = 1800_000
    case hour = 3600_000
    case infinity = -1
    
    var timer: Int{
        switch self{
        case .infinity:
            return -1
        case .ten:
            return 600_000
        case .thirty:
            return 1800_000
        case .hour:
            return 3600_000
        }
    }
    
    
}
public struct GameTimer{
    public var initialTime: TimerSeting
    public var whitePlayerRemainingTimeMillis: Int?
    public var blackPlayerRemainingTimeMillis: Int?
    
    public init(initialTime: TimerSeting) {
        self.initialTime = initialTime
        if initialTime != TimerSeting.infinity{
            self.whitePlayerRemainingTimeMillis = initialTime.timer
            self.blackPlayerRemainingTimeMillis = initialTime.timer
        }
        
    }
}
