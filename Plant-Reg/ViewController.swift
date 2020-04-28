//
//  ContentView.swift
//  Plant-Reg
//
//  Created by Willer AI on 2020/4/9.
//  Copyright © 2020 Willer AI. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var probsLabel: UILabel!
    
    // GhostNetiOS or GhostNetiOSFP16 or GhostNetiOSINT8 or GhostNetiOSINT4
    let model = GhostNetiOSINT8()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = ""
        probsLabel.text  = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        imagePicker.delegate   = self
        imagePicker.sourceType = .photoLibrary

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openPhotoLibrary(_ sender: Any) {
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func predict(_ sender: Any) {
            
        guard let image = imageView.image,
            let resized = image.resize(size: CGSize(width: 512, height: 512)),
            let ref     = resized.buffer else {
            return
        }
 
        do {
            
            let starttimeInterval: TimeInterval = Date().timeIntervalSince1970
            let start = CLongLong(round(starttimeInterval*1000))
        
            let output = try model.prediction(input_1: ref)
            // let output = try plantModel.prediction(input_1: ref)
            let label = output._990
            let endtimeInterval: TimeInterval = Date().timeIntervalSince1970
            let end = CLongLong(round(endtimeInterval*1000))
                      
            var res: [Float32] = [label[0].floatValue, label[1].floatValue, label[2].floatValue, label[3].floatValue]

            //let minProb = res.min()! - 1
            for i in 0 ..< res.count{
                res[i] = exp(res[i])
            }
            let sum = res.reduce(0, +)
            for i in 0 ..< res.count{
                res[i] /= sum
            }

            let result = ["Healthy", "Multiple Diseases", "Rust", "Scab"]
            let index = res.firstIndex(of: res.max()!)!

            resultLabel.text = "Label : \(result[index])"
            probsLabel.text = """
                Run Time:\(end-start) ms
            """
            probsLabel.text = """
                Healthy: \(String(format: "%.3f", res[0]))
                Multiple Diseases: \(String(format: "%.3f", res[1]))
                Rust: \(String(format: "%.3f", res[2]))
                Scab: \(String(format: "%.3f", res[3]))

                Run Time:\(end-start) ms
            """
            print(res)
        } catch {
            print(error)
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    
        guard let image = info[.originalImage] as? UIImage,
            let resized = image.resize(size: CGSize(width: 512, height: 512)) else {
                return
        }
        imageView.image  = resized
        resultLabel.text = ""
        probsLabel.text  = ""
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
