import XCTest

class URLSessionExample {
    let completedRequest: () -> ()
    
    init(completion: @escaping () -> ()) {
        completedRequest = completion
    }
    
    func makeRequestCapturingSelfStrongly() {
        let task = URLSession.shared.dataTask(with: URL(string: "https://www.apple.com")!, completionHandler: { _, _, _  in
            self.completedRequest()
        })
        task.resume()
    }

    func makeRequestCapturingSelfWeakly() {
        let task = URLSession.shared.dataTask(with: URL(string: "https://www.apple.com")!, completionHandler: { [weak self] _, _, _  in
            DispatchQueue.main.async {
                self?.completedRequest()
            }
        })
        task.resume()
    }

    func makeRequestCapturingInnerSelfWeakly() {
        let task = URLSession.shared.dataTask(with: URL(string: "https://www.apple.com")!, completionHandler: { _, _, _  in
            DispatchQueue.main.async { [weak self] in
                self?.completedRequest()
            }
        })
        task.resume()
    }
    
    func makeRequestNotCallingResume() {
        URLSession.shared.dataTask(with: URL(string: "https://www.apple.com")!, completionHandler: { _, _, _  in
            self.completedRequest()
        })
    }
}

class URLSessionByExampleTests: XCTestCase {
    func testLeak1() {
        let expectation = self.expectation(description: "")
        weak var testObject: URLSessionExample?
        
        autoreleasepool {
            let example = URLSessionExample(completion: {
                expectation.fulfill()
            })
            example.makeRequestCapturingSelfStrongly()
            
            testObject = example
        }
        
        XCTAssertNotNil(testObject)
        
        XCTWaiter().wait(for: [expectation], timeout: 10)

        XCTAssertNil(testObject)
    }

    func testLeak2() {
        weak var testObject: URLSessionExample?
        
        autoreleasepool {
            let example = URLSessionExample(completion: { })
            example.makeRequestCapturingSelfWeakly()
            
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }

    func testLeak3() {
        let expectation = self.expectation(description: "")
        weak var testObject: URLSessionExample?
        
        autoreleasepool {
            let example = URLSessionExample(completion: {
                expectation.fulfill()
            })
            example.makeRequestCapturingInnerSelfWeakly()
            
            testObject = example
        }
        
        XCTAssertNotNil(testObject)
        
        XCTWaiter().wait(for: [expectation], timeout: 5)

        XCTAssertNil(testObject)
    }
    
    func testLeak4() {
        let expectation = self.expectation(description: "")
        weak var testObject: URLSessionExample?
        
        autoreleasepool {
            let example = URLSessionExample(completion: {
                expectation.fulfill()
            })
            example.makeRequestNotCallingResume()
            
            testObject = example
        }

        XCTWaiter().wait(for: [expectation], timeout: 1)

        XCTAssertNil(testObject)
    }
}
