//
//  EventsService.swift
//  Febrewary
//
//  Created by Matthew Dias on 6/29/19.
//  Copyright © 2019 Matt Dias. All rights reserved.
//

import Foundation

struct EventsService {
    var client: ServiceClient
    
    init(client: ServiceClient = ServiceClient()) {
        self.client = client
    }
    
    func getAllEventsForCurrentUser(completionHandler: @escaping (Result<[Event], Error>) -> Void) {
        let url = URLBuilder(endpoint: .eventsForCurrentUser).buildUrl()
        
        client.get(url: url) { result in
            switch result {
            case .success(let json):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                guard let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                    let events = try? decoder.decode([Event].self, from: data) else {
                        print("bad data")
                        return
                }
                completionHandler(.success(events))
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func createEvent(named name: String,
                     on date: Date,
                     at address: String,
                     withPourer pourerId: Int,
                     andAttendees attendees: [Int],
                     completionHandler: @escaping (Result<Event, Error>) -> Void) {
        
        let url = URLBuilder(endpoint: .eventsForCurrentUser).buildUrl() // FIXME: change url when networking re-thought out
        let payload: JSON = [
            "name": name,
            "date": date.iso8601,
            "address": address,
            "pourerId": pourerId,
            "attendees": attendees
        ]
        
        client.post(url: url, payload: payload) { result in
            switch result {
            case .success(let eventJson):
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                guard let data = try? JSONSerialization.data(withJSONObject: eventJson, options: .prettyPrinted),
                    let event = try? decoder.decode(Event.self, from: data) else {
                        print("bad data")
                        return
                }
                
                completionHandler(.success(event))
                
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
