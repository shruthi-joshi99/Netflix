//
//  Data.swift
//  CoolTV2
//
//  Created by Shantanu Joshi on 18/01/24.
//

import Foundation

struct MovieData {
    
    let sectionType: String
    let movies: [String]
    
}


var data = [MovieData(sectionType: "Comedy", movies: ["Big Buck Bunny", "For Bigger Joyrides", "For Bigger Escapes", "For Bigger Fun"]),
            MovieData(sectionType: "Suspense", movies: ["For Bigger Blazes", "For Bigger Meltdowns", "Elephants Dream", "Subaru Outback On Street And Dirt"]),
            MovieData(sectionType: "Action", movies: ["Tears Of Steel", "Sintel", "We Are Going On A Bullrun", "What Car Can You Get For A Grand"]),
            MovieData(sectionType: "Top Rated", movies: ["For Bigger Blazes", "Big Buck Bunny", "For Bigger Fun", "Sintel"])]
var movieName = ""
var urlString = ""
var downloads: [String: URL] = [:]

