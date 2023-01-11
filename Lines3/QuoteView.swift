//
//  QuoteView.swift
//  Lines3
//
//  Created by Elie Cohen on 1/8/23.
//

import Charts
import SwiftUI

enum ChartRange: String, CaseIterable, Identifiable {
    case d3m, q
    var id: Self {self}
}

struct SingleTickerQuote: Identifiable {
    var id: UUID
    let key: String
    let day: Date
    let rawDate: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let aClose: Double
    let volume: Double

    init?(csv: String) {
        let fields = csv.components(separatedBy: ",")
        guard fields.count > 3 else {return nil}
        self.id = UUID()
        self.key = fields[0]
        // let dateString = "2021-12-25"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        //let date = dateFormatter.date(from: dateString)
        self.day = dateFormatter.date(from:fields[1])!
        self.rawDate = fields[1]
        self.open = Double(fields[2]) ?? 0.0
        self.high = Double(fields[3]) ?? 0.0
        self.low = Double(fields[4]) ?? 0.0
        self.close = Double(fields[5]) ?? 0.0
        self.aClose = Double(fields[6]) ?? 0.0
        self.volume = (Double(fields[7]) ?? 0.0)/1_000_000
    }
}


struct StatItems: Identifiable {
    var id: UUID
    var minLow: Double
    var maxHigh: Double
    var avgClose: Double
    var lastClose: Double
    var count: Int
    var maxVolume: Double
    var lastDay: String
    
    init (minLow: Double, maxHigh: Double, avgClose: Double, lastClose: Double, count: Int, maxVolume: Double, lastDay: String) {
        self.id = UUID()
        self.minLow = minLow
        self.maxHigh = maxHigh
        self.avgClose = avgClose
        self.lastClose = lastClose
        self.count = count
        self.maxVolume = maxVolume
        self.lastDay = lastDay
    }
}

struct QuoteView: View {
    let company: String
    let urlBase: String
    let ticker: String

    @State private var items = [SingleTickerQuote]()
    @State private var stats = StatItems(minLow: 0.0, maxHigh:  0.0, avgClose: 0.0, lastClose: 0.0, count: 0, maxVolume: 0.0, lastDay: "2000-01-01")
    @State private var selectedRange: ChartRange = .d3m
    
    var body: some View {
        VStack {
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
            Picker("Range", selection: $selectedRange.animation(.easeOut(duration: 1))) {
                Text("daily").tag(ChartRange.d3m)
                Text("quarterly").tag(ChartRange.q)
            }
            .pickerStyle(.segmented)
            .background(Color.green.opacity(0.5))
            ScrollView(.vertical,showsIndicators: false) {
                ZStack {
                    Chart (items) {
                        RectangleMark(
                            x: .value("Date", $0.day),
                            yStart: .value("Start", 0),
                            yEnd: .value("Close", $0.close),
                            width: 4
                        )
                        .foregroundStyle(Color.green.opacity(0.8))
                        RectangleMark(
                            x: .value("Date", $0.day),
                            yStart: .value("", 0),
                            yEnd: .value("High", $0.volume/stats.maxVolume*stats.maxHigh/5),
                            width: 4
                        )
                        .foregroundStyle(Color.blue.opacity(0.3))
                    }
                    .frame(height: 400)
                    .padding(.horizontal)
                    .background()
                    .accentColor(/*@START_MENU_TOKEN@*/.pink/*@END_MENU_TOKEN@*/)
                }
                .onChange(of: selectedRange) { range in
                    switch range {
                    case .d3m:
                        loadData(rangeCode: "D3M")
                    case .q:
                        loadData(rangeCode: "Q")
                    }
                }
                .onAppear() {
                    loadData(rangeCode: "D3M")
                }
                .background(Color.green.opacity(0.3))
            }
        }
    }
    
    func loadData(rangeCode: String) {
        var minLow = Double.greatestFiniteMagnitude
        var maxHigh = 0.0
        var maxVolume = 0.0
        var totClose = 0.0
        var itemCount = 0
        var lastDate = ""
        
        items.removeAll()
        let urlString = "https://drive.google.com/uc?id=\(urlBase)"
        print(urlString)
        let url = URL(string: urlString)!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                //                print ("Error: \(error)")
            } else if let data = data, let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let text = String(data: data, encoding: .utf8) {
                        let lines = text.components(separatedBy: "\n")
                        for line in lines {
                            if let item = SingleTickerQuote(csv: line) {
                                if item.key == "\(ticker).\(rangeCode)" {
                                    items.append(item)
                                    itemCount += 1
                                    totClose += item.close
                                    stats.lastClose = item.close
                                    if item.low < minLow {
                                        minLow = item.low
                                        stats.minLow = minLow
                                    }
                                    if item.high > maxHigh {
                                        maxHigh = item.high
                                        stats.maxHigh = maxHigh
                                    }
                                    if item.volume > maxVolume {
                                        maxVolume = item.volume
                                        stats.maxVolume = item.volume
                                    }
                                    lastDate = item.rawDate
                                }
                            }
                        }
                        stats.avgClose = totClose / Double(itemCount)
                        stats.count = itemCount
                        
                        
                        let dateString = lastDate
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"

                        if let date = dateFormatter.date(from: dateString) {
                            dateFormatter.dateFormat = "dd-MMM-yyyy"
                            let formattedDate = dateFormatter.string(from: date)
                            print(formattedDate) // "31-Jan-2023"
                            stats.lastDay = formattedDate
                        } else {
                            print("Invalid date string")
                            stats.lastDay = ""
                        }

                    } else {
                        print("could not convert data to string")
                    }
                } else {
                    print("non 200 error")
                }
            }
        }.resume()
    }
}

struct QuoteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            QuoteView(company: "Alphabet", urlBase: "19TDFpg-if9cbsz_QwPP0MIa3xQreb3M-", ticker: "GOOG")
                .navigationTitle("<")
        }
    }
}
