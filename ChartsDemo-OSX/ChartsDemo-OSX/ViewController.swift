import Cocoa
import Charts

class BarDemoViewController: NSViewController
{
	@IBOutlet var barChartView: BarChartView!

	override func viewDidLoad()
    {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		let xs = Array(1..<10).map { return Double($0) }
		let ys1 = xs.map { i in return sin(Double(i / 2.0 / 3.141 * 1.5)) }
		let ys2 = xs.map { i in return cos(Double(i / 2.0 / 3.141)) }

		let yse1 = ys1.enumerate().map { idx, i in return BarChartDataEntry(value: i, xIndex: idx) }
		let yse2 = ys2.enumerate().map { idx, i in return BarChartDataEntry(value: i, xIndex: idx) }

		let data = BarChartData(xVals: xs)
		let ds1 = BarChartDataSet(yVals: yse1, label: "Hello")
		ds1.colors = [NSUIColor.redColor()]
		data.addDataSet(ds1)

		let ds2 = BarChartDataSet(yVals: yse2, label: "World")
		ds2.colors = [NSUIColor.blueColor()]
		data.addDataSet(ds2)
		self.barChartView.data = data

		self.barChartView.gridBackgroundColor = NSUIColor.whiteColor()
	}

	@IBAction func save(sender: AnyObject)
    {
		let panel = NSSavePanel()
		panel.allowedFileTypes = ["png"]
		panel.beginSheetModalForWindow(self.view.window!) { (result) -> Void in
			if result == NSFileHandlingPanelOKButton
            {
				if let path = panel.URL?.path
                {
					self.barChartView.saveToPath(path, format: .PNG, compressionQuality: 1.0)
				}
			}
		}
	}

	override func viewWillAppear()
    {
		self.barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
	}
}

class LineDemoViewController: NSViewController
{
	@IBOutlet var lineChartView: LineChartView!

	override func viewDidLoad()
    {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		let xs = Array(1..<10).map { return Double($0) }
		let ys1 = xs.map { i in return sin(Double(i / 2.0 / 3.141 * 1.5)) }
		let ys2 = xs.map { i in return cos(Double(i / 2.0 / 3.141)) }

		let yse1 = ys1.enumerate().map { idx, i in return ChartDataEntry(value: i, xIndex: idx) }
		let yse2 = ys2.enumerate().map { idx, i in return ChartDataEntry(value: i, xIndex: idx) }

		let data = LineChartData(xVals: xs)
		let ds1 = LineChartDataSet(yVals: yse1, label: "Hello")
		ds1.colors = [NSUIColor.redColor()]
		data.addDataSet(ds1)

		let ds2 = LineChartDataSet(yVals: yse2, label: "World")
		ds2.colors = [NSUIColor.blueColor()]
		data.addDataSet(ds2)
		self.lineChartView.data = data

		self.lineChartView.gridBackgroundColor = NSUIColor.whiteColor()
	}

	override func viewWillAppear()
    {
		self.lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
	}
}

class RadarDemoViewController: NSViewController
{
	@IBOutlet var radarChartView: RadarChartView!

	override func viewDidLoad()
    {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		let xs = Array(1..<10).map { return Double($0) }
		let ys1 = xs.map { i in return sin(Double(i / 2.0 / 3.141 * 1.5)) }
		let ys2 = xs.map { i in return cos(Double(i / 2.0 / 3.141)) }

		let yse1 = ys1.enumerate().map { idx, i in return ChartDataEntry(value: i, xIndex: idx) }
		let yse2 = ys2.enumerate().map { idx, i in return ChartDataEntry(value: i, xIndex: idx) }

		let data = RadarChartData(xVals: xs)
		let ds1 = RadarChartDataSet(yVals: yse1, label: "Hello")
		ds1.colors = [NSUIColor.redColor()]
		data.addDataSet(ds1)

		let ds2 = RadarChartDataSet(yVals: yse2, label: "World")
		ds2.colors = [NSUIColor.blueColor()]
		data.addDataSet(ds2)
		self.radarChartView.data = data
	}

	override func viewWillAppear()
    {
		self.radarChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
	}
}

class PieDemoViewController: NSViewController
{
	@IBOutlet var pieChartView: PieChartView!

	override func viewDidLoad()
    {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		let xs = Array(1..<10).map { return Double($0) }
		let ys1 = xs.map { i in return abs(sin(Double(i / 2.0 / 3.141 * 1.5)) * 100) }

		let yse1 = ys1.enumerate().map { idx, i in return ChartDataEntry(value: i, xIndex: idx) }

		let data = PieChartData(xVals: xs)
		let ds1 = PieChartDataSet(yVals: yse1, label: "Hello")
        
		ds1.colors = ChartColorTemplates.vordiplom()
        
        data.addDataSet(ds1)
        
        let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .ByTruncatingTail
        paragraphStyle.alignment = .Center
        let centerText: NSMutableAttributedString = NSMutableAttributedString(string: "iOS Charts\nby Daniel Cohen Gindi")
        centerText.setAttributes([NSFontAttributeName: NSFont(name: "HelveticaNeue-Light", size: 15.0)!, NSParagraphStyleAttributeName: paragraphStyle], range: NSMakeRange(0, centerText.length))
        centerText.addAttributes([NSFontAttributeName: NSFont(name: "HelveticaNeue-Light", size: 13.0)!, NSForegroundColorAttributeName: NSColor.grayColor()], range: NSMakeRange(10, centerText.length - 10))
        centerText.addAttributes([NSFontAttributeName: NSFont(name: "HelveticaNeue-LightItalic", size: 13.0)!, NSForegroundColorAttributeName: NSColor(red: 51 / 255.0, green: 181 / 255.0, blue: 229 / 255.0, alpha: 1.0)], range: NSMakeRange(centerText.length - 19, 19))
        
        self.pieChartView.centerAttributedText = centerText
        
        self.pieChartView.data = data
    }
    
	override func viewWillAppear()
    {
		self.pieChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
	}
}
