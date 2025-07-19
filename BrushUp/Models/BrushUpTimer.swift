//
//  PaintMeTimer.swift
//  Model
//
//  Created by Yuki Suzuki on 7/12/25.
//

import Foundation
import TimerKit
import AVFoundation

@MainActor
@Observable public final class BrushUpTimer {
    // Pure Timer to render/fetch Image through API call
    
    public var currentImageUrl = ""
    /// The number of seconds
    public var secondsElapsed = 0
    /// The number of seconds
    public var secondsRemaining = 0
    
    /// The scrum meeting length.
    private var lengthInMinutes: Int
    private weak var timer: Timer?
    private var timerStopped = false
    private var frequency: TimeInterval { 1.0 / 60.0 }
    private var lengthInSeconds: Int { lengthInMinutes * 60 }
    
    private var startDate: Date?
    private var delayDate: Date?
    
    private let player = AVPlayer.dingPlayer()
    
    public init(lengthInMinutes: Int) {
        self.lengthInMinutes = lengthInMinutes
        self.secondsRemaining = lengthInSeconds
    }
    
    public init(){
        let value = UserDefaults.standard.string(forKey: "minutes")
        let minutes: Int = Int(value ?? "1")!
        
        self.lengthInMinutes = minutes
        self.secondsRemaining = lengthInSeconds
    }
    
    public func start() {

        timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true){
            [weak self] timer in self?.update()
        }
        timer?.tolerance = 0.1
        startDate = Date()
    }
    
    public func toggleTimer(){
        timerStopped = !timerStopped
        //start
        if(!timerStopped){
            let secondsElapsed = Double(Date().timeIntervalSince1970 - delayDate!.timeIntervalSince1970)
            startDate?.addTimeInterval(secondsElapsed)
        }else{
            //stop
            delayDate = Date()
        }
    }
    
    public func endTimer(){
        timer?.invalidate()
        timerStopped = true
    }
    
    public func reset(){
        let value = UserDefaults.standard.string(forKey: "minutes")
        let minutes: Int = Int(value ?? "1")!
        
        self.lengthInMinutes = minutes
        self.secondsRemaining = lengthInSeconds
    }
    
    
    nonisolated private func update() {

        Task{ @MainActor in
            
            guard let startDate, !timerStopped else { return }
            
            let secondsElapsed = Int(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)
            
            let previousSecondsElapsed = self.secondsElapsed
            self.secondsElapsed = secondsElapsed
           
            
            self.secondsRemaining = max(lengthInSeconds - self.secondsElapsed, 0)
            
            if(self.secondsRemaining%60 == 0){
                player.seek(to: .zero)
                player.play()
            }

        }
    }
    
    
    
}
