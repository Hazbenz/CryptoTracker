//
//  CryptoCompare.swift
//  Stock
//
//  Created by Julio Rosario on 9/21/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation

struct CryptoCompare {
    static let market: String = "USD"
    static var limit: String = "60"
    
    static let baseUrl   = "https://www.cryptocompare.com"
    static let priceUrl  = "https://min-api.cryptocompare.com/data/pricemultifull?"
    static let minUrl = "https://min-api.cryptocompare.com/data/histominute?"
    static let hourUrl  = "https://min-api.cryptocompare.com/data/histohour?"
    static let dailyUrl = "https://min-api.cryptocompare.com/data/histoday?"
    static let coinListUrl = "https://min-api.cryptocompare.com/data/all/coinlist"
    static let multiPriceUrl = "https://min-api.cryptocompare.com/data/pricemultifull?"
    
    static  func priceRequest(for crypto: [Cryptocurrency], start: Int, end: Int) -> [String: String] {
        
        var cryptos = "";
        
        for i in start..<end {
            if i != end-1 {
                cryptos += crypto[i].symbol + ","
            } else {
                cryptos += crypto[i].symbol
            }
        }
        return ["fsyms": cryptos,
                "tsyms": market]
    }
    
    static func getPriceRequest(for crypto:  Cryptocurrency)-> [String: String]  {
        return ["fsym": crypto.symbol,
                "tsyms": market]
    }
    
   static   func histRequest(for crypto: Cryptocurrency) -> [String: String] {
        return ["fsym": crypto.symbol,
               "tsym": market,
               "limit": limit]
    }
    
  static  func allDataRequest(for crypto: Cryptocurrency) -> [String: String] {
        return ["fsym": crypto.symbol,
                "tsym": market,
                "allData":"true"]
    }
}
