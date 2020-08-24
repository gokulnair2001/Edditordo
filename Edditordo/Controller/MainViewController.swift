//
//  ViewController.swift
//  Edditordo
//
//  Created by Gokul Nair on 23/08/20.
//  Copyright © 2020 Gokul Nair. All rights reserved.
//

import UIKit
import CoreImage

class MainViewController: UIViewController {
    
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var AddLabel: UILabel!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var changefilterBtn: UIButton!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var removeImage: UIButton!
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var filtername: UILabel!
    
    var context: CIContext!
    var filter: CIFilter!
    
    let haptic = haptickFeedback()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageBackgroundView.layer.cornerRadius = 20
        changefilterBtn.layer.cornerRadius = 20
        saveBtn.layer.cornerRadius = 10
        AddLabel.isHidden = false
        addImage.isHidden = false
        saveBtn.isHidden = true
        removeImage.isHidden = true
        filtername.isHidden = true
        
        context = CIContext()
        filter = CIFilter(name: "CISepiaTone")
        
        intensitySlider.value = 0
        
    }
    
    @IBAction func addImage(_ sender: Any) {
        haptic.haptiFeedback1()
        setupImageSelection()
    }
    @IBAction func removeImageBtn(_ sender: Any) {
        ImageView.image = nil
        AddLabel.isHidden = false
        addImage.isHidden = false
        filtername.isHidden = true
        haptic.haptiFeedback1()
    }
    
}

//MARK:- Image Selection

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        AddLabel.isHidden = true
        addImage.isHidden = true
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.ImageView.image = image
        self.saveBtn.isHidden = false
        self.removeImage.isHidden = false
        
        let beginImage = CIImage(image: image!)
        filter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
        
    }
    
    func applyProcessing() {
        
        let inputKeys = filter.inputKeys
        let currentImage = ImageView.image
        
        if inputKeys.contains(kCIInputIntensityKey){
            filter.setValue(intensitySlider.value, forKey: kCIInputIntensityKey)
        }
        
        if inputKeys.contains(kCIInputRadiusKey){
            filter.setValue(intensitySlider.value * 200, forKey: kCIInputRadiusKey)
        }
        
        if inputKeys.contains(kCIInputScaleKey){
            filter.setValue(intensitySlider.value * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey){
            filter.setValue(CIVector(x: currentImage!.size.width/2, y: currentImage!.size.height/2), forKey: kCIInputCenterKey)
        }
        
        guard let outputmage = filter.outputImage else {return}
        
        if let cgImage = context.createCGImage(filter.outputImage!, from: filter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgImage)
            ImageView.image = processedImage
        }
    }
    
    private func setupImageSelection(){
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }
        
    }
    
    
}

//MARK:- Intensity Method

extension MainViewController {
    @IBAction func intensityChangeSlider(_ sender: Any) {
        
        if ImageView.image != nil {
            
            applyProcessing()
            
        }
        else {
            let alert = UIAlertController(title: nil, message: "Add Image", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
}


//MARK:- Filter options

extension MainViewController{
    @IBAction func changeFilterBtn(_ sender: UIButton) {
        
        if ImageView.image != nil {
            
            let alert = UIAlertController(title: "Filter Options", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
            alert.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
            alert.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
            alert.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
            alert.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
            alert.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
            alert.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            
            if let popOverController = alert.popoverPresentationController{
                popOverController.sourceView = sender
                popOverController.sourceRect = sender.bounds
            }
            
            present(alert, animated: true)
        }
        else {
            let alert = UIAlertController(title: nil, message: "Add Image", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
        haptic.haptiFeedback1()
    }
    
    func setFilter(action: UIAlertAction){
        
        if ImageView.image != nil {
            
            guard let actionTitle = action.title else{return}
            
            filter = CIFilter(name: actionTitle)
            
            guard let beginImage = CIImage(image: ImageView.image!) else {return}
            filter.setValue(beginImage, forKey: kCIInputImageKey)
            
            applyProcessing()
            filterLabel(action: action)
        }
        else{
            let alert = UIAlertController(title: nil, message: "Add Image", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
    }
}


//MARK:- Image save btn methods

extension MainViewController {
    
    @IBAction func saveBtn(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(ImageView.image!, self, #selector(image(_:didfinishSavingwithError:contextInfo:)), nil)
        haptic.haptiFeedback1()
    }
    
    @objc func image(_ image: UIImage, didfinishSavingwithError error: Error?, contextInfo: UnsafeRawPointer){
        
        if let error = error {
            let alert = UIAlertController(title: "Error-Occoured", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
        else{
            let alert = UIAlertController(title: "Saved!", message: "Your edited image is saved into gallery", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
        
    }
}

//MARK:- Filter image name label method

extension MainViewController{
    func filterLabel(action: UIAlertAction){
        filtername.text = action.title
        filtername.isHidden = false
    }
}
