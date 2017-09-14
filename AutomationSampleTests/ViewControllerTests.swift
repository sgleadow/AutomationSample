import XCTest
@testable import AutomationSample

struct FakeToggle: ToggleType {
    let enabled: Bool
}

class ViewControllerTests: XCTestCase {
    
    var vc: ViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        vc = storyboard.instantiateInitialViewController() as! ViewController
    }
    
    func test_whenToggledOff_shouldHideWorkInProgress() {
        vc.shouldShowTheThang = FakeToggle(enabled: false)
        _ = vc.view
        
        XCTAssertTrue(vc.button.isHidden)
    }
    
    func test_whenToggledOn_shouldShowWorkInProgress() {
        vc.shouldShowTheThang = FakeToggle(enabled: true)
        _ = vc.view
        
        XCTAssertFalse(vc.button.isHidden)
    }
}
