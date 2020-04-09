import XCTest
import Capacitor
@testable import Plugin

struct JSONTest: Decodable {
    var userId: Int
    var id: Int
    var title: String
    var completed: Bool
}

class PluginTests: XCTestCase {
     override func setUp() {
         super.setUp()
         // Put setup code here. This method is called before the invocation of each test method in the class.
     }
    
     override func tearDown() {
         // Put teardown code here. This method is called after the invocation of each test method in the class.
         super.tearDown()
     }
    
     func testEcho() {
        let urlSessonConfiguration = URLSessionConfiguration.default
        let client = Rest(urlSessionConfiguration: urlSessonConfiguration)
        let expectation = XCTestExpectation(description: "Get data from example api, parse it")
        
        client.run(method: .get, url: "https://jsonplaceholder.typicode.com/todos/1", data: nil, completion: { result in
            switch result {
                case .success(let parsed):
                    let body = parsed["body"] as! Dictionary<String, Any>
                    XCTAssertEqual(body["userId"] as! Int, 1)
                    XCTAssertEqual(body["id"] as! Int, 1)
                    XCTAssertEqual(body["title"] as! String, "delectus aut autem")
                    XCTAssertEqual(body["completed"] as! Bool, false)
                    expectation.fulfill()
                case .failure(.anyerror(let description)):
                    XCTFail(description)
                    expectation.fulfill()
            }
        })
        
        wait(for: [expectation], timeout: 10.0)
     }
}
