import XCTest

class ClassExample {
    var closure: () -> () = { }
    var innerClosure: () -> () = { }
    
    func captureSelfStrongly() {
        closure = {
            _ = self
        }
    }
    
    func captureSelfWeakly() {
        closure = { [weak self] in
            _ = self
        }
    }
    
    func captureInnerSelfStrongly() {
        closure = { [weak self] in
            guard let `self` = self else { return }
            
            self.innerClosure = {
                _ = self
            }
        }
        closure()
    }
    
    func captureInnerSelfWeakly() {
        closure = { [weak self] in
            self?.innerClosure = { [weak self] in
                _ = self
            }
        }
        closure()
    }
    
    func captureSelfStronglyWithinTransientClosure() {
        var transientClosure: (() -> ())?

        closure = {
            transientClosure = {
                _ = self
            }
        }
    }
    
    func releaseClosure() {
        closure = { }
    }
}

class ClassesByExampleTests: XCTestCase {
    func testLeak1() {
        weak var testObject = ClassExample()
        
        autoreleasepool {
            let example = ClassExample()
            example.captureSelfStrongly()
            
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }

    func testLeak2() {
        weak var testObject = ClassExample()
        
        autoreleasepool {
            let example = ClassExample()
            example.captureSelfWeakly()
            
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak3() {
        weak var testObject = ClassExample()
        
        autoreleasepool {
            let example = ClassExample()
            example.captureInnerSelfStrongly()
            
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak4() {
        weak var testObject = ClassExample()
        
        autoreleasepool {
            let example = ClassExample()
            example.captureInnerSelfWeakly()
            
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak5() {
        weak var testObject = ClassExample()
        
        autoreleasepool {
            let example = ClassExample()
            example.captureSelfStronglyWithinTransientClosure()
            
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak6() {
        weak var testObject = ClassExample()
        
        autoreleasepool {
            let example = ClassExample()
            example.captureSelfStrongly()
            
            testObject = example
            
            example.releaseClosure()
        }
        
        XCTAssertNil(testObject)
    }
}
