import XCTest

class URLSessionExample {
    private let completedRequest: () -> ()
    
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

class CancelRequestBeforeCompletion {
    private var task: URLSessionDataTask?
    var handleResult: (Data?) -> () = { _ in }
    
    func completeWithIncorrectUsageOfWeakSelf(url: URL) {
        task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async { [weak self] in
                self?.handleResult(data)
            }
        }
        task?.resume()
    }

    func completeWithWeakSelf(url: URL) {
        task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleResult(data)
            }
        }
        task?.resume()
    }

    deinit {
        task?.cancel()
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
    
    func testLeak5() {
        let expectation = self.expectation(description: "")
        expectation.isInverted = true

        weak var testObject: CancelRequestBeforeCompletion?
        
        autoreleasepool {
            let example = CancelRequestBeforeCompletion()
            example.handleResult = { _ in
                expectation.fulfill()
            }
            example.completeWithIncorrectUsageOfWeakSelf(url: URL(string: "https://www.apple.com")!)
            
            testObject = example
        }
        
        XCTWaiter().wait(for: [expectation], timeout: 0)
        
        XCTAssertNil(testObject)
    }
    
    func testLeak6() {
        let expectation = self.expectation(description: "")
        expectation.isInverted = true

        weak var testObject: CancelRequestBeforeCompletion?
        
        autoreleasepool {
            let example = CancelRequestBeforeCompletion()
            example.handleResult = { _ in
                expectation.fulfill()
            }
            example.completeWithWeakSelf(url: URL(string: "https://www.apple.com")!)
            
            testObject = example
        }
        
        XCTWaiter().wait(for: [expectation], timeout: 0)
        
        XCTAssertNil(testObject)
    }
}
