//
//  Date+Extensions.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import Foundation

/// Extensões úteis para Date
extension Date {
    /// Retorna uma string formatada para exibição no diário
    /// - Returns: String formatada (ex: "Hoje", "Ontem", "15 de Dezembro")
    func formattedForDiary() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(self) {
            return "Hoje"
        } else if calendar.isDateInYesterday(self) {
            return "Ontem"
        } else if calendar.isDate(self, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self).capitalized
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            formatter.locale = Locale(identifier: "pt_BR")
            return formatter.string(from: self)
        }
    }
    
    /// Retorna uma string com data e hora formatada
    /// - Returns: String formatada (ex: "15 de Dezembro de 2024, 14:30")
    func formattedWithTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: self)
    }
    
    /// Retorna apenas a hora formatada
    /// - Returns: String formatada (ex: "14:30")
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: self)
    }
}

