import XCTest

class ClassExample {
    private var closure: () -> () = { }
    private var innerClosure: () -> () = { }
    
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
    
    func captureOuterSelfStronglyInnerSelfWeakly() {
        var transientClosure: (() -> ())?

        closure = {
            transientClosure = { [weak self] in

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
            transientClosure?()
        }
    }
    
    func captureImplicitSelfFromFunction() {
        takeClosureArgument(releaseClosure)
    }

    func captureImplicitSelfFromFunction2() {
        closure = { [weak self] in
            if let block = self?.releaseClosure {
                self?.takeClosureArgument(block)
            }
        }
        closure()
    }

    func captureImplicitSelfWeaklyFromFunction() {
        closure = { [weak self] in
            self?.takeClosureArgument({
                self?.releaseClosure()
            })
        }
        closure()
    }
    
    func takeClosureArgument(_ fn: @escaping () -> ()) {
        closure = fn
    }
    
    func releaseClosure() {
        closure = { }
    }
}

class ImplicitlyReleasingClosure {
    var capturedClosure: (() -> ())?
    
    func doStuff(_ closure: @escaping () -> ()) {
        self.capturedClosure = {
            _ = self
            closure()
        }
        deferWork()
    }
    
    private func deferWork() {
        if let closure = self.capturedClosure {
            self.capturedClosure = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                closure()
            })
        }
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
    
    func testLeak7() {
        weak var testObject = ClassExample()
        
        autoreleasepool {
            let example = ClassExample()
            example.captureImplicitSelfFromFunction()
            
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak8() {
        weak var testObject = ClassExample()
        
        autoreleasepool {
            let example = ClassExample()
            example.captureImplicitSelfFromFunction2()
            
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak9() {
        weak var testObject = ClassExample()
        
        autoreleasepool {
            let example = ClassExample()
            example.captureImplicitSelfWeaklyFromFunction()
            
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak10() {
        let expectation = self.expectation(description: "")
        weak var testObject = ImplicitlyReleasingClosure()
        
        autoreleasepool {
            let example = ImplicitlyReleasingClosure()
            example.doStuff {
                expectation.fulfill()
            }
            
            testObject = example
        }
        
        XCTAssertNotNil(testObject)
        
        XCTWaiter().wait(for: [expectation], timeout: 0.7)
        
        XCTAssertNil(testObject)
    }
    
    func testLeak11() {
        class Person {
            var pet: Pet?
        }
        
        class Pet {
            var owner: Person?
        }
        
        var person: Person? = Person()
        let pet = Pet()
        
        person?.pet = pet
        pet.owner = person
        
        weak var testObject = person
        person = nil
        XCTAssertNil(testObject)
    }
}
