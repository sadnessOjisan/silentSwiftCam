//
//  ViewController.swift
//  silentCam
//
//  Created by ide yuta on 2019/03/01.
//  Copyright © 2019年 ojisan. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var cameraView: UIImageView!
    
    @IBOutlet weak var shutterButton: UIButton!
    
    var captureSesssion: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    
    @IBAction func shutterCamera(_ sender: UIButton) {
        let settingsForMonitoring = AVCapturePhotoSettings()
        settingsForMonitoring.flashMode = .auto
        settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingsForMonitoring.isHighResolutionPhotoEnabled = false
        // シャッターを切る
         stillImageOutput?.capturePhoto(with: settingsForMonitoring, delegate: self)
        var soundIdRing:SystemSoundID = 0
        if let soundUrl:NSURL = NSURL(fileURLWithPath:
            Bundle.main.path(forResource: "unShutter", ofType:"caf")!) as NSURL?{
            AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
            AudioServicesPlaySystemSound(soundIdRing)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        captureSesssion = AVCaptureSession()
        stillImageOutput = AVCapturePhotoOutput()
        
        captureSesssion.sessionPreset = AVCaptureSession.Preset.hd1920x1080 // 解像度の設定1920x1080
        
        let device = AVCaptureDevice.default(for: .video)
        
        do {
            let input = try AVCaptureDeviceInput(device: device!)
            // 入力
            if (captureSesssion.canAddInput(input)) {
                captureSesssion.addInput(input)
                // 出力
                if (captureSesssion.canAddOutput(stillImageOutput!)) {
                    captureSesssion.addOutput(stillImageOutput!)
                    captureSesssion.startRunning() // カメラ起動
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                    previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect // アスペクトフィット
                    previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait // カメラの向き
                    cameraView.layer.addSublayer(previewLayer!)
                    // ビューのサイズの調整
                    previewLayer?.position = CGPoint(x: self.cameraView.frame.width / 2, y: self.cameraView.frame.height / 2)
                    previewLayer?.bounds = cameraView.frame
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let photoSampleBuffer = photoSampleBuffer {
            // JPEG形式で画像データを取得
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let image = UIImage(data: photoData!)
            
            // フォトライブラリに保存
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

