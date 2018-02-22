//
//  TestChartsAnimatedHighlighting.swift
//  ChartsTests
//
//  Created by Azamat Kalmurzayev on 2/22/18.
//

import XCTest
@testable import Charts

/// Mock class for AnimatorDelegate method implementation 
fileprivate class MockPieChartAnimatorDelegate: AnimatorDelegate {
    var animationInvokeFlag = false
    func animatorUpdated(_ animator: Animator) {
        animationInvokeFlag = true
    }
    func animatorStopped(_ animator: Animator) { }
}

class TestChartsAnimatedHighlighting: XCTestCase {
    private var freshMockInstance: PieChartView {
        let chartView = PieChartView()
        let entries = [
            PieChartDataEntry(value: 100),
            PieChartDataEntry(value: 100),
            PieChartDataEntry(value: 100)
        ]
        let set = PieChartDataSet(values: entries, label: "Test Pie")
        let data = PieChartData(dataSet: set)
        chartView.data = data
        return chartView
    }
    func testWhenHighlightAnimationDisabled() {
        let chartView = freshMockInstance
        let delegate = MockPieChartAnimatorDelegate()
        chartView.chartAnimator.delegate = delegate
        XCTAssertFalse(delegate.animationInvokeFlag)
        chartView.highlightValue(chartView.highlighted.first, callDelegate: false)
        XCTAssertFalse(delegate.animationInvokeFlag,
                       "still haven't called animator delegate functions")
        
    }
    
    func testWhenHighlightAnimationEnabled() {
        let chartView = freshMockInstance
        let set = chartView.data as? PieChartData
        set?.dataSet?.isSelectionAnimated = true;
        let delegate = MockPieChartAnimatorDelegate()
        chartView.chartAnimator.delegate = delegate
        XCTAssertFalse(delegate.animationInvokeFlag)
        chartView.highlightValue(chartView.highlighted.first, callDelegate: false)
        
        if let duration = set?.dataSet?.selectionShiftDuration {
            let exp = expectation(description: "waiting for animation duration");
            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.01) {
                exp.fulfill();
            }
            waitForExpectations(timeout: duration + 0.02, handler: nil);
        }
        XCTAssertTrue(delegate.animationInvokeFlag,
                       "animator delegate function should be called")
    }
    
}
