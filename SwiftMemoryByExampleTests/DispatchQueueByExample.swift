import XCTest

class DispatchQueueExample {
    private let dispatchQueue: DispatchQueue
    private var closure: () -> () = { }
    
    init(dispatchQueue: DispatchQueue = .main) {
        self.dispatchQueue = dispatchQueue
    }
    
    func callStrongly() {
        dispatchQueue.asyncAfter(deadline: .now() + 0.1) {
            self.closure()
        }
    }
    
    func callWeakly() {
        dispatchQueue.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.closure()
        }
    }
    
    func callInnerQueueWeakly() {
        dispatchQueue.asyncAfter(deadline: .now() + 0.05) {
            self.dispatchQueue.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.closure()
            }
        }
    }
}


class DispatchQueueByExampleTests: XCTestCase {
    func testLeak1() {
        weak var testObject: DispatchQueueExample?
    
        autoreleasepool {
            let example = DispatchQueueExample()
            example.callStrongly()
            
            testObject = example
        }
        
        XCTAssertNotNil(testObject)
        
        RunLoop.current.run(until: Date().addingTimeInterval(0.12))

        XCTAssertNil(testObject)
    }
    
    func testLeak2() {
        weak var testObject: DispatchQueueExample?
        
        autoreleasepool {
            let example = DispatchQueueExample()
            example.callWeakly()
            
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak3() {
        weak var testObject: DispatchQueueExample?
        
        autoreleasepool {
            let example = DispatchQueueExample()
            example.callInnerQueueWeakly()
            
            testObject = example
        }
        
        XCTAssertNotNil(testObject)
        
        RunLoop.current.run(until: Date().addingTimeInterval(0.06))
        
        XCTAssertNil(testObject)
    }
}
