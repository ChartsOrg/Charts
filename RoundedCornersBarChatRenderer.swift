import Foundation

open class RoundedCornersBarChatRenderer: BarChartRenderer {
    
    open var cornerRadius: CGFloat = 0.0
    
    open var corners: UIRectCorner = [.allCorners]
        
    open override func drawDataSet(context: CGContext, dataSet: IBarChartDataSet, index: Int) {
        drawDataSet(context: context, dataSet: dataSet, index: index, cornerRadius: cornerRadius, roundedCorners: corners)
    }

    init?(renderer: DataRenderer?) {
        guard let renderer = renderer as? BarChartRenderer, let dataProvider = renderer.dataProvider else { return nil }

        super.init(dataProvider: dataProvider, animator: renderer.animator, viewPortHandler: renderer.viewPortHandler)
    }
}
