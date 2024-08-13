//
//  QuoteData.swift
//  TaskIT
//
//  Created by Ansh Bajpai on 25/05/22.
//

import UIKit


// This class, is a decodable class used to parse json data recived from Quote API
class QuoteData: NSObject, Decodable {
    
    var content: String
    
    // Coding Keys, according to the paramters we require
    private enum CodingKeys: String, CodingKey {
        case content = "content"
    }


}
