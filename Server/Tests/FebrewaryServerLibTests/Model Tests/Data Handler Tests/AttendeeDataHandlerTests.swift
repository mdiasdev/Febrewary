//
//  AttendeeDataHandlerTests.swift
//  FebrewaryServerLibTests
//
//  Created by Matthew Dias on 10/19/19.
//

import XCTest

@testable import FebrewaryServerLib

class AttendeeDataHandlerTests: XCTestCase {

    static var allTests = [
        ("test_attendeeFromEventAndUserIds_returnsAttendee_whenOneInTheDatabase", test_attendeeFromEventAndUserIds_returnsAttendee_whenOneInTheDatabase),
        ("test_attendeeFromEventAndUserIds_doesNotThrow_whenOneInTheDatabase", test_attendeeFromEventAndUserIds_doesNotThrow_whenOneInTheDatabase),
        ("test_attendeeFromEventAndUserIds_throws_whenNoneInTheDatabase", test_attendeeFromEventAndUserIds_throws_whenNoneInTheDatabase),
        ("test_attendeeFromEventAndUserIds_throws_whenManyInTheDatabase", test_attendeeFromEventAndUserIds_throws_whenManyInTheDatabase),
        ("test_attendeeFromUserId_returnsTwoAttendee_whenInDatabase", test_attendeeFromUserId_returnsTwoAttendee_whenInDatabase),
        ("test_attendeeFromUserId_throws_whenNoneInTheDatabase", test_attendeeFromUserId_throws_whenNoneInTheDatabase)
    ]
    
    var sut: AttendeeDataHandler!
    
    override func setUp() {
        super.setUp()
        
        sut = AttendeeDataHandler()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }

    // MARK: attendee from eventId and userId
    func test_attendeeFromEventAndUserIds_returnsAttendee_whenOneInTheDatabase() {
        let mockAttendeeDAO = MockSingleAttendeeDAO()
        
        let expectedAttendee = try! sut.attendee(fromEventId: 1, andUserId: 1, attendeeDAO: mockAttendeeDAO)
        
        XCTAssertEqual(1, expectedAttendee.id)
    }
    
    func test_attendeeFromEventAndUserIds_doesNotThrow_whenOneInTheDatabase() {
        let mockAttendeeDAO = MockSingleAttendeeDAO()
        
        XCTAssertNoThrow(try sut.attendee(fromEventId: 1,
                                          andUserId: 1,
                                          attendeeDAO: mockAttendeeDAO))
    }
    
    func test_attendeeFromEventAndUserIds_throws_whenNoneInTheDatabase() {
        let mockAttendeeDAO = MockNoAttendeeDAO()
        
        XCTAssertThrowsError(try sut.attendee(fromEventId: 1,
                                              andUserId: 1,
                                              attendeeDAO: mockAttendeeDAO)) { error in
            XCTAssertTrue(error is UserNotInvitedError)
        }
    }
    
    func test_attendeeFromEventAndUserIds_throws_whenManyInTheDatabase() {
        let mockAttendeeDAO = MockManyAttendeeDAO()
        
        XCTAssertThrowsError(try sut.attendee(fromEventId: 1,
                                              andUserId: 1,
                                              attendeeDAO: mockAttendeeDAO)) { error in
            XCTAssertTrue(error is UserNotInvitedError)
        }
    }
    
    // MARK: attendees from userId
    func test_attendeeFromUserId_returnsTwoAttendee_whenInDatabase() {
        let mockAttendeeDAO = MockManyAttendeeDAO()
        
        let expectedAttendees = try! sut.attendees(fromUserId: 1, attendeeDAO: mockAttendeeDAO)
        
        XCTAssertEqual(2, expectedAttendees.count)
    }
    
    func test_attendeeFromUserId_throws_whenNoneInTheDatabase() {
        let mockAttendeeDAO = MockNoAttendeeDAO()
        
        XCTAssertThrowsError(try sut.attendees(fromUserId: 1,
                                              attendeeDAO: mockAttendeeDAO)) { error in
            XCTAssertTrue(error is DatabaseError)
        }
    }
    
    // MARK: save attendee
    func test_save_setsAttendeeId() {
        let mockAttendeeDAO = MockSingleAttendeeDAO()
        var attendee = Attendee(id: 0, eventId: 1, eventBeerId: 1, userId: 1)
        
        try! sut.save(attendee: &attendee, attendeeDAO: mockAttendeeDAO)
        
        XCTAssertEqual(1, attendee.id)
    }
}
