import UIKit
import AVFoundation

protocol ScanViewControllerDelegate {
    func codeDetected(code:String)
}

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var delegate:ScanViewControllerDelegate?
    
    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                              AVMetadataObjectTypeCode39Code,
                              AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeCode93Code,
                              AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypeEAN8Code,
                              AVMetadataObjectTypeEAN13Code,
                              AVMetadataObjectTypeAztecCode,
                              AVMetadataObjectTypePDF417Code,
                              AVMetadataObjectTypeQRCode]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = LocalizeUtil.string(name: "scanner")
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            let captureMetadataOutput = AVCaptureMetadataOutput()
            
            if let captureSession = captureSession {
                captureSession.addInput(input)
                captureSession.addOutput(captureMetadataOutput)
            }
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            if let captureSession = captureSession {
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                if let videoPreviewLayer = videoPreviewLayer {
                    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    videoPreviewLayer.frame = view.layer.bounds
                    view.layer.addSublayer(videoPreviewLayer)
                }
                
                captureSession.startRunning()
            }
            
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            print(error)
            return
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.frame = CGRect.zero
                print("No code is detected")
            }
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                print(metadataObj.stringValue)
                if let delegate = delegate {
                    delegate.codeDetected(code: metadataObj.stringValue)
                }
                if let navigationController = navigationController {
                    navigationController.popViewController(animated: true)
                    if let captureSession = captureSession {
                        captureSession.stopRunning()
                    }
                }
            }
        }
    }
}
