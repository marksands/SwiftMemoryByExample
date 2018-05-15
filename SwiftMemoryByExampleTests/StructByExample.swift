import XCTest
import SwiftMemoryByExample

class ClassContainingStruct {
    private var structReference: StructByExample?
    
    init(referenceSemantics: ReferenceSemantics = .strong) {
        if referenceSemantics == .strong {
            structReference = StructByExample(closure: {
                _ = self
            })
        } else if referenceSemantics == .unowned {
            structReference = StructByExample(closure: { [unowned self] in
                _ = self
            })
        }
    }
}

struct StructByExample {
    private var closure: () -> ()
    
    init(closure: @escaping () -> ()) {
        self.closure = closure
    }
}

protocol ClassWithStructDelegateProviding: class {
    func display()
}

class ExampleClassWithStructDelegateProviding: ClassWithStructDelegateProviding {
    var structDelegate = ExampleStructAsDelegate()
    
    init(referenceSemantics: ReferenceSemantics = .strong) {
        if referenceSemantics == .strong {
            structDelegate.delegate = self
        } else if referenceSemantics == .weak {
            structDelegate.weakDelegate = self
        }
    }
    
    func display() {
        
    }
}

struct ExampleStructAsDelegate {
    var delegate: ClassWithStructDelegateProviding?
    weak var weakDelegate: ClassWithStructDelegateProviding?

    func display() {
        delegate?.display() ?? weakDelegate?.display()
    }
}

class StructMemoryByExampleTests: XCTestCase {
    func testLeak() {
        weak var testObject: ClassContainingStruct?
        
        autoreleasepool {
            let example = ClassContainingStruct(referenceSemantics: .strong)
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak2() {
        weak var testObject: ClassContainingStruct?
        
        autoreleasepool {
            let example = ClassContainingStruct(referenceSemantics: .unowned)
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak3() {
        weak var testObject: ExampleClassWithStructDelegateProviding?
        
        autoreleasepool {
            let example = ExampleClassWithStructDelegateProviding(referenceSemantics: .strong)
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak4() {
        weak var testObject: ExampleClassWithStructDelegateProviding?
        
        autoreleasepool {
            let example = ExampleClassWithStructDelegateProviding(referenceSemantics: .weak)
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
}
