//
//  CompaniesView.swift
//  Lines
//
//  Created by Elie Cohen on 12/23/22.
//

import SwiftUI

struct DirectoryItem: Identifiable, Hashable {
    let company: String
    let id: String
    let ticker: String
    
    init?(csv: String) {
        let fields = csv.components(separatedBy: ",")
        guard fields.count > 1 else {return nil}
        self.company = fields[0]
        self.ticker = fields[1]
        let chunks = fields[2].components(separatedBy: "/")
        guard chunks.count > 4 else {return nil}
        self.id = chunks[5]
    }
}

struct CompaniesView: View {
    @State private var tables = [DirectoryItem]()
    
    var body: some View {
        NavigationStack {
            List(tables, id:\.self) { table in
                NavigationLink {
                    QuoteView(company: table.company, urlBase: table.id, ticker: table.ticker)
                } label: {
                    HStack {
                        Text(table.company)
                            .font(.body)
                    }
                }
            }
            .navigationBarTitle("Companies", displayMode: .automatic)
        }
        .onAppear {
//            tables.removeAll()
            let googleDriveFileID = "1M-A9bL1EmTjJTM1g6C7v0NS0mIJPk40h"
            let urlString = "https://drive.google.com/uc?id=\(googleDriveFileID)"
            print(urlString)
            let url = URL(string:urlString)!

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let _ = error {
                    // handle the error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let text = String(data: data, encoding: .utf8) {
                            let lines = text.components(separatedBy: "\n")
                            for line in lines {
                                let item = DirectoryItem(csv: line)!
                                tables.append(item)
                            }
                        } else {
                            // handle error: could not convert data to string
                        }
                    } else {
                        // handle non-200 status code
                    }
                }
            }.resume()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CompaniesView()
    }
}
