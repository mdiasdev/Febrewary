//
//  EventRouter.swift
//  FebrewaryServerLib
//
//  Created by Matthew Dias on 7/30/19.
//

import Foundation
import PerfectHTTP

public class EventRouter: Router {
    override func initRoutes() {
        routes.add(method: .post, uri: "/event", handler: auth &&& createEvent)
        routes.add(method: .get, uri: "/event", handler: auth &&& getEventForUser)
        routes.add(method: .post, uri: "/event/{id}/beer", handler: auth &&& addEventBeer)
        routes.add(method: .put, uri: "/event/{id}/attendee", handler: auth &&& addAttendee)
        routes.add(method: .get, uri: "/event/{id}/pour", handler: auth &&& pourEventBeer)
        routes.add(method: .get, uri: "/event/{id}/currentbeer", handler: auth &&& getCurrentEventBeer)
        routes.add(method: .post, uri: "/event/{id}/vote", handler: auth &&& vote)
    }
    
    func createEvent(request: HTTPRequest, response: HTTPResponse) {
        EventController().createEvent(request: request, response: response)
    }
    
    func getEventForUser(request: HTTPRequest, response: HTTPResponse) {
        EventController().getEventForUser(request: request, response: response)
    }
    
    func addEventBeer(request: HTTPRequest, response: HTTPResponse) {
        EventController().addEventBeer(request: request, response: response)
    }
    
    func addAttendee(request: HTTPRequest, response: HTTPResponse) {
        EventController().addAttendee(request: request, response: response)
    }
    
    func pourEventBeer(request: HTTPRequest, response: HTTPResponse) {
        EventController().pourEventBeer(request: request, response: response)
    }
    
    func getCurrentEventBeer(request: HTTPRequest, response: HTTPResponse) {
        EventController().getCurrentEventBeer(request: request, response: response)
    }
    
    func vote(request: HTTPRequest, response: HTTPResponse) {
        EventController().vote(request: request, response: response)
    }
}
