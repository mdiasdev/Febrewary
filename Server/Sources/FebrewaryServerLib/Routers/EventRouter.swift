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
        routes.add(method: .post, uri: "/event", handler: createEvent)
        routes.add(method: .get, uri: "/event/{id}", handler: getEvent)
        routes.add(method: .get, uri: "/event", handler: getEventForUser)
        routes.add(method: .post, uri: "/event/{id}/beer", handler: addEventBeer)
        routes.add(method: .put, uri: "/event/{id}/attendee", handler: addAttendee)
        routes.add(method: .get, uri: "/event/{id}/pour", handler: pourEventBeer)
        routes.add(method: .get, uri: "/event/{id}/currentbeer", handler: getCurrentEventBeer)
    }
    
    func createEvent(request: HTTPRequest, response: HTTPResponse) {
        EventController().createEvent(request: request, response: response)
    }
    
    func getEvent(request: HTTPRequest, response: HTTPResponse) {
        EventController().getEvent(request: request, response: response)
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
}
