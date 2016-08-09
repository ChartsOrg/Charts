//
//  KlineChartDataEntry.swift
//  Charts
//
//  Created by 迅牛 on 16/6/16.
//  Copyright © 2016年 dcg. All rights reserved.
//

import UIKit

public class KlineChartDataEntry: CandleChartDataEntry {
    var volume:Double = 0.0;
    
    var _qualificationType:KlineQualification = .KDJ
    
    public required init()
    {
        super.init()
    }
    public override init(xIndex: Int, shadowH: Double, shadowL: Double, open: Double, close: Double)
    {
        super.init(xIndex: xIndex, shadowH: shadowH, shadowL: shadowL, open: open, close: close)
    }
    
    public override init(xIndex: Int, shadowH: Double, shadowL: Double, open: Double, close: Double, data: AnyObject?)
    {
        super.init(xIndex: xIndex, shadowH: shadowH, shadowL: shadowL, open: open, close: close, data:data)
    }
    
    
    public init(xIndex: Int, shadowH: Double, shadowL: Double, open: Double, close: Double, volume: Double) {
        self.volume = volume;
        super.init(xIndex: xIndex, shadowH: shadowH, shadowL: shadowL, open: open, close: close)
    }
    
    public init(xIndex: Int, shadowH: Double, shadowL: Double, open: Double, close: Double, volume: Double, data: AnyObject?) {
        self.volume = volume;
        super.init(xIndex: xIndex, shadowH: shadowH, shadowL: shadowL, open: open, close: close, data:data)
    }
    
//    var MA5:Double = 0.0;
//    var MA10:Double = 0.0
//    var MA30:Double = 0.0
    var EMA5:Double {
        get {
           return EMAValueFor(num: 5)
        } set {
            setEMAValueFor(num: 5, val: newValue)
        }
    }

    var EMA10:Double {
        get {
           return EMAValueFor(num: 10)
        } set {
            setEMAValueFor(num: 10, val: newValue)
        }
    }
    
    var EMA30:Double {
        get {
          return  EMAValueFor(num: 30)
        } set {
            setEMAValueFor(num: 30, val: newValue)
        }
    }
    var volume_MA5:Double = 0.0
    var volume_MA10:Double = 0.0
    var volume_MA30:Double = 0.0
    var DIF:Double = 0.0
    var DEA:Double = 0.0
    var MACD:Double = 0.0
    var KDJ_K:Double = 0.0
    var KDJ_D:Double = 0.0
    var KDJ_J:Double = 0.0
    var RSV_9:Double = 0.0
    var NineClocksMin:Double = 0.0
    var NineClocksMax:Double = 0.0
    
    var nineClocksNeedCacl:Bool = true
        
    weak var lastEntry:KlineChartDataEntry?
    weak var dataSet:KlineChartDataSet?
    
    lazy var EMAValueDict:Dictionary<Int,Double> = {
        var dic = [Int: Double]()
        return dic;
    }()
    
    lazy var volumMAValueDict:Dictionary<Int,Double> = {
        var dic = [Int: Double]()
        return dic;
    }()
    
    public func EMAValueFor(num num: Int) -> Double {
        
        let ema = EMAValueDict[num]
        if ema != nil {
            return ema!
        }
        return close;
    }
    public func setEMAValueFor(num num: Int, val:Double) {
        
        EMAValueDict[num] = val
    }
    
    public func volumMAValueFor(num num: Int) -> Double {
        
        let ema = volumMAValueDict[num]
        if ema != nil {
            return ema!
        }
        return volume;
    }
    public func setvolumMAValueFor(num num: Int, val:Double) {
        
        volumMAValueDict[num] = val
    }

    public func calcQualification()  {
        
        if lastEntry == nil {
            NineClocksMax = high
            NineClocksMin = low
        } else {
        }
        switch _qualificationType {
        case .KDJ:
            caclNineMaxANDNineMin()
            caclRSV_9()
            caclKDJ()
            
        case .MACD:
            caclDIF()
            caclDEA()
            caclMACD()
        case .VOL:
            caclVolum()
        case .RSI: break
        case .BIAS: break
        case .BOLL: break
        case .WR: break
        case .ASI: break
        }
    }
    
    func caclMA() {
    
    }
    
    func caclVolum() {
        
        if volume_MA5 == 0 {
            volume_MA5 = caclVolumMA(num: 5);
        }

    }
    func caclEMA() {
        
        EMA5 = caclEMAFor(num: 5);
        EMA10 = caclEMAFor(num: 10);
        EMA30 = caclEMAFor(num: 30);
    }
    
    func caclDIF() {
        if DIF == 0 {
            DIF = caclEMAFor(num: 12) - caclEMAFor(num: 26)
        }

    }
    func  caclDEA () {
        if DEA == 0 {
            if lastEntry == nil {
                DEA = DIF * 0.2
            } else {
                DEA = (lastEntry?.DEA)! * 0.8 + DIF * 0.2
            }
        }

    }
    func caclMACD() {
        
        if MACD == 0 {
            MACD = (DIF - DEA) * 2
        }
    }
    func caclRSV_9 () {
        
        if RSV_9 == 50 || RSV_9 == 0{
            
            if NineClocksMax <= NineClocksMin {
                RSV_9 = 50.0;
            } else {
                RSV_9 = (close - NineClocksMin) / (NineClocksMax - NineClocksMin) * 100.0
            }
        }

    }
    func caclKDJ() {
        
        if (KDJ_K == 0 || KDJ_K == 50) && (KDJ_D == 0 || KDJ_D == 50) {
            
            if lastEntry == nil {
                KDJ_K = (RSV_9 + 2.0 * 50.0) / 3.0
                KDJ_D = (KDJ_K + 2.0 * 50.0) / 3.0
                KDJ_J = (3 * KDJ_K - 2 * KDJ_D)
            } else {
                KDJ_K = (RSV_9 + 2.0 * lastEntry!.KDJ_K) / 3.0
                KDJ_D = (KDJ_K + 2.0 * lastEntry!.KDJ_D) / 3.0
                KDJ_J = (3 * KDJ_K - 2 * KDJ_D)
            }
        }

    }
    func caclNineMaxANDNineMin() {
        
        guard nineClocksNeedCacl
            else { return }
         nineClocksNeedCacl = false
        
        let curIndex = (dataSet?.yVals.indexOf(self))
        
        if (curIndex < 9) {
            if lastEntry == nil {
                NineClocksMax = high
                NineClocksMin = low
            } else {
                NineClocksMin = min((lastEntry?.NineClocksMin)!, low)
                NineClocksMax = max((lastEntry?.NineClocksMax)!, high)
            }

        } else {
            
            let entry = dataSet?.yVals[curIndex! - 9] as! KlineChartDataEntry;
            
            if entry.low == lastEntry?.NineClocksMin {
                
                let subVals = Array(dataSet!.yVals[(curIndex! - 8)..<curIndex!+1]).map({ (entry) -> Double in
                    return (entry as! KlineChartDataEntry).low
                })
                let min :Double =  (subVals as NSArray).valueForKeyPath("@min.doubleValue") as! Double
                
                NineClocksMin = min
                
            } else {
                NineClocksMin = min((lastEntry?.NineClocksMin)!, low)
            }
            if entry.high == lastEntry?.NineClocksMax {
                
                let subVals = Array(dataSet!.yVals[(curIndex! - 8)..<curIndex!+1]).map({ (entry) -> Double in
                    return (entry as! KlineChartDataEntry).high
                })
                let max :Double =  (subVals as NSArray).valueForKeyPath("@max.doubleValue") as! Double
                
                NineClocksMax = max
                
            } else {
                NineClocksMax = max((lastEntry?.NineClocksMax)!, high)
            }
        }

    }
    
    public func caclVolumMA(num num:Int) -> Double {
     
        
        if dataSet == nil {
            setvolumMAValueFor(num: num, val: volume)
            return volume
        }
        
        let yVals = dataSet!.yVals
        let index:Int = yVals.indexOf(self)!
        
        let ema = volumMAValueDict[num]
        
        guard ema == nil
            else
        {
            return ema!
        }
        
        if index == 0 {
            setvolumMAValueFor(num: num, val: volume)
            return volume
        }
        
        let subVals = Array(yVals[max(0,index - (num - 1))..<index+1]).map({ (entry) -> Double in
            
            return  (entry as! KlineChartDataEntry).volume;
        })
        let avg:Double =  (subVals as NSArray).valueForKeyPath("@avg.doubleValue") as! Double
        
        setvolumMAValueFor(num: num, val: avg)
        return avg
    }
    
    public func caclEMAFor(num num: Int) -> Double {
        
        
        if dataSet == nil {
            setEMAValueFor(num: num, val: close)
            return close
        }
        
        let yVals = dataSet!.yVals
        let index:Int = yVals.indexOf(self)!
        
        let ema = EMAValueDict[num]
        
        guard ema == nil
            else
        {
            return ema!
        }
        
        if index == 0 {
            setEMAValueFor(num: num, val: close)
            return close
        }
        
//        if index < num { 
//            let subVals = Array(yVals[0..<index+1]).map({ (entry) -> Double in
//                
//                return entry.value;
//            })
//            let avg:Double =  (subVals as NSArray).valueForKeyPath("@avg.doubleValue") as! Double
//            
//            setEMAValueFor(num: num, val: avg)
//            return avg
//        } else {
        let a = yVals[index].value * 2 / Double(num + 1)
        let b  = (lastEntry?.caclEMAFor(num: num))! * ( Double(num - 1) / Double(num + 1))
        let avg = a + b
        return avg
//        }
        
//        return
    }

}
