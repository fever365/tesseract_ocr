import Flutter
import UIKit
import SwiftyTesseract

public class SwiftFlutterTesseractOcrPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_tesseract_ocr", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterTesseractOcrPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //initializeTessData()
        if call.method == "extractText" {
            
            guard let args = call.arguments else {
                result("iOS could not recognize flutter arguments in method: (sendParams)")
                return
            }
    // Move data from bundle to documents directory /tessdata
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    // this directory will contain our traineddata and is what we will pass to the data source
    let tessData = documentsURL!.appendingPathComponent("tessdata")
    // setup the data source class
    struct MyDataSource: LanguageModelDataSource {
        let pathToTrainedData: String
    }

    let dataSource = MyDataSource(pathToTrainedData: tessData.path)
            let params: [String : Any] = args as! [String : Any]
            let language: String? = params["language"] as? String
            var  swiftyTesseract: SwiftyTesseract;
            if(language != nil){
                swiftyTesseract = SwiftyTesseract(language: .custom (language as String!), dataSource: dataSource)
            } else {
                swiftyTesseract = SwiftyTesseract(language: .english, dataSource: dataSource)
            }
            let  imagePath = params["imagePath"] as! String
            guard let image = UIImage(contentsOfFile: imagePath)else { return }
            
            swiftyTesseract.performOCR(on: image) { recognizedString in
                
                guard let extractText = recognizedString else { return }
                result(extractText)
            }
        }
    }
    
    func initializeTessData() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destURL = documentsURL!.appendingPathComponent("tessdata")
        
        let sourceURL = Bundle.main.bundleURL.appendingPathComponent("tessdata")
        
        let fileManager = FileManager.default
        do {
            try fileManager.createSymbolicLink(at: sourceURL, withDestinationURL: destURL)
        } catch {
            print(error)
        }
    }
}
