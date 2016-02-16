import Cocoa
import Charts

class BarDemoViewController: NSViewController {
	@IBOutlet var barChartView: BarChartView!

	override func viewDidLoad() {
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

	@IBAction func save(sender: AnyObject) {
		let panel = NSSavePanel()
		panel.allowedFileTypes = ["png"]
		panel.beginSheetModalForWindow(self.view.window!) { (result) -> Void in
			if result == NSFileHandlingPanelOKButton {
				if let path = panel.URL?.path {
					self.barChartView.saveToPath(path, format: .PNG, compressionQuality: 1.0)
				}
			}
		}
	}

	override func viewWillAppear() {
		self.barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
	}
}

class LineDemoViewController: NSViewController {
	@IBOutlet var lineChartView: LineChartView!

	override func viewDidLoad() {
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

	override func viewWillAppear() {
		self.lineChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
	}
}

class RadarDemoViewController: NSViewController {
	@IBOutlet var radarChartView: RadarChartView!

	override func viewDidLoad() {
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

	override func viewWillAppear() {
		self.radarChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
	}
}

class PieDemoViewController: NSViewController {
	@IBOutlet var pieChartView: PieChartView!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		let xs = Array(1..<10).map { return Double($0) }
		let ys1 = xs.map { i in return abs(sin(Double(i / 2.0 / 3.141 * 1.5)) * 100) }

		let yse1 = ys1.enumerate().map { idx, i in return ChartDataEntry(value: i, xIndex: idx) }

		let data = PieChartData(xVals: xs)
		let ds1 = PieChartDataSet(yVals: yse1, label: "Hello")
		ds1.colors = [NSUIColor.redColor(), NSUIColor.blueColor(), NSUIColor.greenColor(), NSUIColor.orangeColor(), NSUIColor.grayColor()]
		data.addDataSet(ds1)

		self.pieChartView.data = data
	}

	override func viewWillAppear() {
		self.pieChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
	}
}
