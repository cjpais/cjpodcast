//
//  DateExtensions.swift
//  cjpodcast
//
//  Created by CJ Pais on 5/1/20.
//  Copyright © 2020 CJ Pais. All rights reserved.
//

import Foundation

let sixHoursInSec: TimeInterval = 60*60*6

extension Date {

    func getMonthDayYear() -> String {
        return getFormat(format: "MMM d, yyyy")
    }
    
    private func getFormat(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // Source: https://gist.github.com/kunikullaya/6474fc6537ed616b1c617646d263555d
    func timeSinceDate(fromDate: Date) -> String {
        let earliest = self < fromDate ? self  : fromDate
        let latest = (earliest == self) ? fromDate : self
    
        let components:DateComponents = Calendar.current.dateComponents([.minute,.hour,.day,.weekOfYear,.month,.year,.second], from: earliest, to: latest)
        let year = components.year  ?? 0
        let month = components.month  ?? 0
        let week = components.weekOfYear  ?? 0
        let day = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        
        
        if year >= 2{
            return "\(year) years ago"
        }else if (year >= 1){
            return "1 year ago"
        }else if (month >= 2) {
             return "\(month) months ago"
        }else if (month >= 1) {
         return "1 month ago"
        }else  if (week >= 2) {
            return "\(week) weeks ago"
        } else if (week >= 1){
            return "1 week ago"
        } else if (day >= 2) {
            return "\(day) days ago"
        } else if (day >= 1){
           return "1 day ago"
        } else if (hours >= 2) {
            return "\(hours) hours ago"
        } else if (hours >= 1){
            return "1 hour ago"
        } else if (minutes >= 2) {
            return "\(minutes) minutes ago"
        } else if (minutes >= 1){
            return "1 minute ago"
        } else if (seconds >= 3) {
            return "\(seconds) seconds ago"
        } else {
            return "Just now"
        }
        
    }
    
}

extension DateFormatter {
}

func getHMS(sec: Int) -> (Int, Int, Int) {
    let hours = sec/3600
    let minutes = (sec % 3600) / 60
    let seconds = sec % 60
    
    return (hours, minutes, seconds)
}

func getHHMMSSFromSec(sec: Int) -> String {
    let (hours, minutes, seconds) = getHMS(sec: sec)
    
    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    
    return String(format: "%d:%02d", minutes, seconds)
}

func getLengthFromSec(sec: Int, started: Bool) -> String {
    var length = ""
    
    let (hours, minutes, seconds) = getHMS(sec: sec)

    if sec > 0 {
        if hours > 0 {
            length += "\(hours)hr"
            if hours > 1 {
                length += "s"
            }
    
            if minutes > 0 {
                length += " \(minutes)min"
            }
        } else if minutes > 0 {
            length += "\(minutes)min"
        } else {
            length += "\(seconds)sec"
        }
    
        if started {
            length += " Remaining"
        }
    } else {
        length = "Completed"
    }
    
    return length
}
