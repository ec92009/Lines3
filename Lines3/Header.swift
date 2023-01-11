//
//  Header.swift
//  Lines3
//
//  Created by Elie Cohen on 1/11/23.
//

import SwiftUI

struct Header: View {
    let vertical: Bool
    let company: String
    let ticker: String
    let stats: StatItems
    
    var body: some View {
        if vertical {
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(company)
                        .font(.largeTitle)
                    Text(ticker)
                        .font(.title)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Average Close: \(String(format: "$%.2f", stats.avgClose))")
                    Text("Min: \(String(format: "$%.2f", stats.minLow))")
                    Text("Max: \(String(format: "$%.2f", stats.maxHigh))")
                    Text("Close: \(String(format: "$%.2f", stats.lastClose))")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.blue)
                    Text("On: \(stats.lastDay)")
                        .foregroundColor(.blue)
                }
                .font(.subheadline)
                Spacer()
            }
            .background(Color.green.opacity(0.3))
    } else {
        VStack(alignment: .trailing) {
            Spacer()
            Text(company)
                .font(.largeTitle)
            Text(ticker)
                .font(.title)
            Spacer()
            Text("Average Close: \(String(format: "$%.2f", stats.avgClose))")
            Text("Min: \(String(format: "$%.2f", stats.minLow))")
            Text("Max: \(String(format: "$%.2f", stats.maxHigh))")
            Text("Close: \(String(format: "$%.2f", stats.lastClose))")
                .font(.title3)
                .bold()
                .foregroundColor(.blue)
            Text("On: \(stats.lastDay)")
                .foregroundColor(.blue)
            Spacer()
        }
        .background(Color.green.opacity(0.3))    }
    }
}

struct Header_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Header(vertical: true, company: "Volkswagen AG", ticker: "VW", stats: StatItems(minLow: 12.0, maxHigh: 120, avgClose: 110, lastClose: 50, count: 91, maxVolume: 120000, lastDay: "2022-12-31"))
            Spacer()
            Header(vertical: false, company: "Volkswagen AG", ticker: "VW", stats: StatItems(minLow: 12.0, maxHigh: 120, avgClose: 110, lastClose: 50, count: 91, maxVolume: 120000, lastDay: "2022-12-31"))
        }
    }
}
