import XCTest

class UIViewAnimationExample: UIView {
    func animateStrongly() {
        UIView.animate(withDuration: 10, animations: {
            self.frame = self.frame.insetBy(dx: -10, dy: -10)
        }, completion: { _ in
            _ = self
        })
    }
    
    func animateWeakly() {
        UIView.animate(withDuration: 10, animations: {
            self.frame = self.frame.insetBy(dx: -10, dy: -10)
        }, completion: { [weak self] _ in
            _ = self
        })
    }
    
    func animateStrongly(withCompletion completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0, animations: {
            self.frame = self.frame.insetBy(dx: -10, dy: -10)
        }, completion: { _ in
            _ = self
            completion()
        })
    }
}

class UIViewAnimationByExampleTests: XCTestCase {
    func testLeak1() {
        weak var testObject: UIViewAnimationExample?
        
        autoreleasepool {
            let example = UIViewAnimationExample()
            example.animateStrongly()
            
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak2() {
        weak var testObject: UIViewAnimationExample?
        
        autoreleasepool {
            let example = UIViewAnimationExample()
            example.animateWeakly()
            
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }

    func testLeak3() {
        let expectation = self.expectation(description: "")
        weak var testObject: UIViewAnimationExample?
        
        autoreleasepool {
            let example = UIViewAnimationExample()
            example.animateStrongly(withCompletion: {
                expectation.fulfill()
            })
            
            testObject = example
        }
        
        XCTWaiter().wait(for: [expectation], timeout: 0.5)
        
        XCTAssertNil(testObject)
    }
}
