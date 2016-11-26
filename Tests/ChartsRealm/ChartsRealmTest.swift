import XCTest
import FBSnapshotTestCase
import Charts
@testable import ChartsRealm

class ChartsRealmTest: FBSnapshotTestCase
{
    override func setUp()
    {
        super.setUp()
        
        // Set to `true` to re-capture all snapshots
        self.recordMode = false
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
