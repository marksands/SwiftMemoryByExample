import XCTest
import SwiftMemoryByExample

enum ContainsEnum {
    case retaining(Example)
    case none
    indirect case containsIndirect(ContainsEnum)
}

class Example {
    private var containsEnum: ContainsEnum?
    
    init() {
        containsEnum = .retaining(self)
    }
    
    static func usingIndirectCase() -> Example {
        let example = Example()
        example.containsEnum = .containsIndirect(.retaining(example))
        return example
    }
    
    func release() {
        containsEnum = ContainsEnum.none
    }
}

class EnumMemoryByExampleTests: XCTestCase {
    func testLeak() {
        weak var testObject: Example?
        
        autoreleasepool {
            let example = Example()
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak2() {
        weak var testObject: Example?
        
        autoreleasepool {
            let example = Example()
            testObject = example
            example.release()
        }
        
        XCTAssertNil(testObject)
    }
    
    func testLeak3() {
        weak var testObject: Example?
        
        autoreleasepool {
            let example = Example.usingIndirectCase()
            testObject = example
        }
        
        XCTAssertNil(testObject)
    }
}
