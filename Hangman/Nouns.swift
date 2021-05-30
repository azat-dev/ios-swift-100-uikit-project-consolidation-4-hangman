//
//  Nouns.swift
//  Hangman
//
//  Created by Azat Kaiumov on 30.05.2021.
//

import Foundation

struct Nouns: Codable {
    let nouns: [String]
}

extension Nouns {
    init?(json: Data) {
        let decoder = JSONDecoder()
        
        guard let data = try? decoder.decode(Nouns.self, from: json) else {
            return nil
        }
        
        self = data
    }
}
