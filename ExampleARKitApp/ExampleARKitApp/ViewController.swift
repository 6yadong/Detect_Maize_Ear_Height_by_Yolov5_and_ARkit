//
//  ViewController.swift
//  ExampleARKitApp
//
//  Created by John Sanderson on 11/09/2017.
//  Copyright © 2017 The App Business. All rights reserved.
//

import UIKit
import Vision
import SceneKit
import ARKit

class ViewController: UIViewController, UIDocumentInteractionControllerDelegate {
  
  @IBOutlet fileprivate var sceneView: ARSCNView!
  @IBOutlet fileprivate var distanceLabel: UILabel!
  @IBOutlet fileprivate var addButton: UIButton!
  @IBOutlet fileprivate var confirmButton: UIButton!
  @IBOutlet fileprivate var instructionLabel: UILabel!
  @IBOutlet fileprivate var crosshairs: [UIView]!
  @IBOutlet fileprivate var DetectingButton: UIButton!


    var documentController:UIDocumentInteractionController!
  @IBOutlet fileprivate var outputbutton: UIButton!
  @IBOutlet fileprivate var PlotNumChanger: UIStepper!
  @IBOutlet fileprivate var PlotNumText: UILabel!

  @IBOutlet var benchmarkLabel: UILabel!
  @IBOutlet var indicator: UIActivityIndicatorView!
  
  fileprivate var planes: [ARPlaneAnchor : SCNNode] = [:]
  fileprivate var squareNode: SCNNode?
  fileprivate var measuringTape: MeasuringTape?
  fileprivate var sphereNode: SCNNode?
//  fileprivate var currentFaceView: UIView?
  fileprivate var shouldPollForFaces: Bool = false
  fileprivate var panGestureRecogniser: UIPanGestureRecognizer = UIPanGestureRecognizer()

  fileprivate var bottomLeftNode: SCNNode?
    fileprivate var bottomMidNode: SCNNode?
    fileprivate var bottomRightNode: SCNNode?
    fileprivate var earNode: SCNNode?
    
    private var inferencer = ObjectDetector()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    sceneView.delegate = self
    sceneView.showsStatistics = true
    confirmButton.isHidden = true

  }
    
    @IBAction fileprivate func preViewDocument(_ sender: AnyObject) {
//        let docUrl = Bundle.main.url(forResource: "earHs", withExtension: "txt")
        let docUrl = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/earHs.txt")
        print("docUrl")
        print(docUrl)
        documentController = UIDocumentInteractionController(url:docUrl)
                documentController.delegate = self;
        //当前APP打开  需实现协议方法才可以完成预览功能
        documentController.presentPreview(animated: true)
        
    }
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
        {
            return self
        }

    @IBAction func didPress(button sender: AnyObject)  {
        let PlotNum = PlotNumChanger.value
        let PlotNumString = String(format: "%.0f", PlotNum)
        PlotNumText.text = "Plot: \(PlotNumString)"
    }


    func convertCIImageToUIImage(ciImage:CIImage) -> UIImage {
        let uiImage = UIImage.init(ciImage: ciImage)
        // 注意！！！这里的uiImage的uiImage.cgImage 是nil
        let cgImage = uiImage.cgImage
        // 注意！！！上面的cgImage是nil，原因如下，官方解释
        // returns underlying CGImageRef or nil if CIImage based
        return uiImage
    }


    
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    createAndStartNewSession()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    sceneView.session.pause()
  }
  
  fileprivate func createAndStartNewSession() {
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    configuration.isLightEstimationEnabled = true
    
    // Run the view's session
    sceneView.session.run(configuration)
    sceneView.automaticallyUpdatesLighting = true
    sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    
    // Update instruction label UI
    instructionLabel.text = "Please move around your world to detect the floor"
  }
  
  @IBAction fileprivate func didTapReset() {
    distanceLabel.text = "Height: ?"
    addButton.isEnabled = true
    addButton.backgroundColor = .defaultOrange
    addButton.isHidden = false
    confirmButton.isHidden = true
    shouldPollForFaces = false
    for view in crosshairs {
      view.isHidden = false
    }
    
    for plane in planes {
      plane.value.removeFromParentNode()
    }
    planes.removeAll()
    
    squareNode?.removeFromParentNode()
    measuringTape?.removeFromParentNode()
    sphereNode?.removeFromParentNode()
//    currentFaceView?.removeFromSuperview()
      
    squareNode = nil
    measuringTape = nil
    sphereNode = nil
      
//    currentFaceView = nil
      earNode?.removeFromParentNode()
      earNode = nil
      bottomLeftNode?.removeFromParentNode()
      bottomMidNode?.removeFromParentNode()
      bottomRightNode?.removeFromParentNode()
      bottomLeftNode = nil
      bottomMidNode = nil
      bottomRightNode = nil
      self.AAAcleanDetection(imageView: sceneView)
    sceneView.session.pause()
    view.removeGestureRecognizer(panGestureRecogniser)
    createAndStartNewSession()
  }
  
//    //      =====
//      @IBAction fileprivate func DetectingButton() {
//          guard let frame = self.sceneView.session.currentFrame else {
//            print("No frame available")
//            return
//          }
//          let image = CIImage(cvPixelBuffer: frame.capturedImage).rotate
//    //      let image = UIImage(cvPixelBuffer: frame.capturedImage).rotate
//    //      CIImage>>>UIImage
//          let ui_image = convertCIImageToUIImage(ciImage: image)
//    //      CIImage.clampedToExtent().cropped(to: CGRect(x: 0, y: 0, width: 100, height: 100))
//    //      let resizedImage = image.transformed(by: CGAffineTransform(scaleX: 10, y: 10))  //ciimage 缩放
//          let resizedImage = ui_image.resized(to: CGSize(width: CGFloat(PrePostProcessor.inputWidth), height: CGFloat(PrePostProcessor.inputHeight)))
//
//          guard var pixelBuffer = resizedImage.normalized() else {
//              return
//          }
//          guard let outputs = self.inferencer.module.detect(image: &pixelBuffer) else {
//              return
//          }
//          print("“outputs”")
//          print(outputs)
//
//          }
//    //      =====
    
 //      =====
    var aaa = 1
    @IBAction fileprivate func DetectingButton1() {
        aaa += 1;
        self.AAAcleanDetection(imageView: sceneView)
        print("PlotNumChanger.value")
        print(PlotNumChanger.value)
      guard let frame = self.sceneView.session.currentFrame else {
        print("No frame available")
        return
      }

      let image = CIImage(cvPixelBuffer: frame.capturedImage).rotate
//      let image = UIImage(cvPixelBuffer: frame.capturedImage).rotate
//      CIImage>>>UIImage
      let ui_image = convertCIImageToUIImage(ciImage: image)
//      CIImage.clampedToExtent().cropped(to: CGRect(x: 0, y: 0, width: 100, height: 100))
//      let resizedImage = image.transformed(by: CGAffineTransform(scaleX: 10, y: 10))  //ciimage 缩放
      let resizedImage = ui_image.resized(to: CGSize(width: CGFloat(PrePostProcessor.inputWidth), height: CGFloat(PrePostProcessor.inputHeight)))

      guard var pixelBuffer = resizedImage.normalized() else {
          return
      }
      guard let outputs = self.inferencer.module.detect(image: &pixelBuffer) else {
          return
      }
        print("<<<<<<<")
      print("“outputs”")
        print(aaa)
//      print(outputs)
        print("sceneView.bounds.size")
        print(sceneView.bounds.size)
        print(sceneView.bounds.size.width)
        print(sceneView.bounds.size.height)
        
//        let ivScaleX : Double =  Double(ui_image.size.width / CGFloat(PrePostProcessor.inputWidth))
//        let ivScaleY : Double = Double(ui_image.size.height / CGFloat(PrePostProcessor.inputHeight))
//        let startX = Double((ui_image.size.width - CGFloat(ivScaleX) * CGFloat(PrePostProcessor.inputWidth))/2)
//        let startY = Double((ui_image.size.height -  CGFloat(ivScaleY) * CGFloat(PrePostProcessor.inputHeight))/2)
        
        
        let ivScaleX : Double =  Double(sceneView.bounds.size.width / CGFloat(PrePostProcessor.inputWidth))
        let ivScaleY : Double = Double(sceneView.bounds.size.height / CGFloat(PrePostProcessor.inputHeight))
        let startX = Double((sceneView.bounds.size.width - CGFloat(ivScaleX) * CGFloat(PrePostProcessor.inputWidth))/2)
        let startY = Double((sceneView.bounds.size.height -  CGFloat(ivScaleY) * CGFloat(PrePostProcessor.inputHeight))/2)
        let nmsPredictions = PrePostProcessor.outputsToNMSPredictions(outputs: outputs, imgScaleX: 1.0, imgScaleY: 1.0, ivScaleX: ivScaleX, ivScaleY: ivScaleY, startX: startX, startY: startY)
        
        DispatchQueue.main.async {
            self.AAAshowDetection(imageView: self.sceneView, nmsPredictions: nmsPredictions, classes: self.inferencer.classes)
            
            //self.AAAcalculateHeight()
        }
        

//        PrePostProcessor.showDetection(imageView: strongSelf.imageViewLive, nmsPredictions: nmsPredictions, classes: strongSelf.inferencer.classes)
        
//        drawFrame(around: bounding_Box)
        print("--")

        print("ui_image.size.width     ui_image.size.height")
        print(ui_image.size.width)
        print(ui_image.size.height)
        print("--")
        print("PrePostProcessor.inputWidth     PrePostProcessor.inputHeight")
        print(PrePostProcessor.inputWidth)
        print(PrePostProcessor.inputHeight)
        print("--")
        print("ivScaleX,ivScaleY,startX,startY")
        print(ivScaleX)
        print(ivScaleY)
        print(startX)
        print(startY)
        print(">>>>>>>>>>>>")
      }
    
    //    //      =====
    

    
  @IBAction fileprivate func didTapAdd() {
//      相机中的二维点 平面
    let point = CGPoint(x: view.frame.origin.x + (view.frame.width / 2), y: view.frame.origin.y + (view.frame.height / 2))
//      二维点point>>>空间三维点 result  平面
    let result = sceneView.hitTest(point, types: .existingPlaneUsingExtent)
    if result.count == 0 {
      return
    }
      print("fileprivate func didTapAdd() ")
      print("point")
      print(point)
    
    for view in crosshairs {
      view.isHidden = true
    }
    
    guard let hitResult = result.first else { return }
    insertReferenceNode(at: hitResult)
  }
  
  @IBAction fileprivate func didTapConfirm() {
    didConfirmFace()
  }
    fileprivate func AAAinsertReferenceNode(at hitResult: ARHitTestResult) -> SCNVector3 {
        let x3 = hitResult.worldTransform.columns.3.x
        let y3 = hitResult.worldTransform.columns.3.y
        let z3 = hitResult.worldTransform.columns.3.z
        let Position3D = SCNVector3Make(x3, y3, z3)
        return(Position3D)}
//      squareNode = node
//      sceneView.scene.rootNode.addChildNode(node)
//
//      addButton.isEnabled = false
//      addButton.backgroundColor = UIColor.lightGray
//
//      shouldPollForFaces = true
//
//      instructionLabel.text = "Please point the camera at the person you would like to measure!"
    
    
  fileprivate func insertReferenceNode(at hitResult: ARHitTestResult) {
    let box = SCNBox(width: 0.2, height: 0.0001, length: 0.2, chamferRadius: 0.0)
    box.firstMaterial?.diffuse.contents = UIColor.defaultOrange
    let node = SCNNode(geometry: box)
    
    node.position = SCNVector3Make(
      hitResult.worldTransform.columns.3.x,
      hitResult.worldTransform.columns.3.y,
      hitResult.worldTransform.columns.3.z
    )
    
    squareNode = node
    sceneView.scene.rootNode.addChildNode(node)
    
    addButton.isEnabled = false
    addButton.backgroundColor = UIColor.lightGray
    
    shouldPollForFaces = true
    
    instructionLabel.text = "Please point the camera at the person you would like to measure!"
  }
   
    func AAAcleanDetection(imageView: ARSCNView) {

        earNode?.removeFromParentNode()
        earNode = nil
        bottomLeftNode?.removeFromParentNode()
        bottomMidNode?.removeFromParentNode()
        bottomRightNode?.removeFromParentNode()
        bottomLeftNode = nil
        bottomMidNode = nil
        bottomRightNode = nil
        if let layers = imageView.layer.sublayers {
            for layer in layers {
                if layer is CATextLayer {
                    layer.removeFromSuperlayer()
                }
            }
            for view in imageView.subviews {
                view.removeFromSuperview()
            }
        }
    }
    func AAAshowDetection(imageView: ARSCNView, nmsPredictions: [Prediction], classes: [String]) {
        var earHs = [Any]()
//        let snapimage = imageView.snapshot()
        for pred in nmsPredictions {
            //检测框
//            let detectedRect = pred.rect
            let bottomLeftPoint = CGPoint(x: pred.rect.origin.x, y: pred.rect.origin.y + pred.rect.height)
            let bottomMidPoint = CGPoint(x: pred.rect.origin.x + (pred.rect.width / 2), y: pred.rect.origin.y + pred.rect.height)
            let bottomRightPoint = CGPoint(x: pred.rect.origin.x + pred.rect.width , y: pred.rect.origin.y + pred.rect.height)
            
            guard let bottomLeftPointHitTest = sceneView.hitTest((bottomLeftPoint), types: [.featurePoint]).first else { return }
            guard let bottomMidPointHitTest = sceneView.hitTest((bottomMidPoint), types: [.featurePoint]).first else { return }
            guard let bottomRightHitTest = sceneView.hitTest((bottomRightPoint), types: [.featurePoint]).first else { return }
            
            let bottomLeftPosition:SCNVector3 = self.AAAinsertReferenceNode(at: bottomLeftPointHitTest)
            let bottomMidPosition:SCNVector3 = self.AAAinsertReferenceNode(at: bottomMidPointHitTest)
            let bottomRightPosition:SCNVector3 = self.AAAinsertReferenceNode(at: bottomRightHitTest)
            let sphere = SCNSphere(radius: 0.01)
            sphere.firstMaterial?.diffuse.contents = UIColor.defaultOrange
            
            let bottomLeftNode = SCNNode(geometry: sphere)
            let bottomMidNode = SCNNode(geometry: sphere)
            let bottomRightNode = SCNNode(geometry: sphere)
//           右手坐标系，靠近照相机，Z值越大
            let leftZ = bottomLeftPosition.z
            let midZ = bottomMidPosition.z
            let rightZ = bottomRightPosition.z
            
            if leftZ > midZ{
                if leftZ > rightZ{
                    print("左大于中，左大于右。检测左下角")
                    bottomLeftNode.position = bottomLeftPosition
                    earNode = bottomLeftNode
                    sceneView.scene.rootNode.addChildNode(earNode!)
//                    let earH = AAAcalculateHeight()
//                    print("earH = AAAcalculateHeight().distance")
//                    print(earH)
//                    earHs.append(earH)
                }}
            
            if midZ > leftZ{
                if midZ > rightZ{
                    print("中大于中，中大于右。检测中间")
                    bottomMidNode.position = bottomMidPosition
                    earNode = bottomMidNode
                    sceneView.scene.rootNode.addChildNode(earNode!)
//                    let earH = AAAcalculateHeight()
//                    print("earH = AAAcalculateHeight().distance")
//                    print(earH)
//                    earHs.append(earH)
                }}
            
            if rightZ > midZ{
                if rightZ > leftZ{
                    print("右大于中，右大于左。检测右下角")
                    bottomRightNode.position = bottomRightPosition
                    earNode = bottomRightNode
                    sceneView.scene.rootNode.addChildNode(earNode!)
//                    let earH = AAAcalculateHeight()
//                    print("earH = AAAcalculateHeight().distance")
//                    print(earH)
//                    earHs.append(earH)
                }}
            let earH = AAAcalculateHeight()
            let plotnum = PlotNumChanger.value
            let deTime = Date()
            print("let earH = AAAcalculateHeight()")
            print(earH)
            
            let resultArray = [deTime,plotnum,earH] as [Any]
            print("resultArray")
            print(resultArray)
            earHs.append(resultArray)
//            earHs.append("earH")
            
           


            
//            bottomLeftNode.position = bottomLeftPosition
//            bottomMidNode.position = bottomMidPosition
//            bottomRightNode.position = bottomRightPosition
            
//            sceneView.scene.rootNode.addChildNode(bottomLeftNode)
//            sceneView.scene.rootNode.addChildNode(bottomMidNode)
//            sceneView.scene.rootNode.addChildNode(bottomRightNode)


          
            
            let bbox = UIView(frame: pred.rect)
            bbox.backgroundColor = UIColor.clear
            bbox.layer.borderColor = UIColor.yellow.cgColor
            bbox.layer.borderWidth = 2
//            view.addSubview(bbox)
            imageView.addSubview(bbox)
//            print("func AAAshowDetection  第275行")
//            print(detectedRect)
//            print(pred.rect)
            
            //置信度
            let textLayer = CATextLayer()
            textLayer.string = String(format: " %@ %.2f", classes[pred.classIndex], pred.score)
            textLayer.foregroundColor = UIColor.white.cgColor
            textLayer.backgroundColor = UIColor.magenta.cgColor
            textLayer.fontSize = 14
            textLayer.frame = CGRect(x: pred.rect.origin.x, y: pred.rect.origin.y, width:100, height:20)
//            view.layer.addSublayer(textLayer)
            imageView.layer.addSublayer(textLayer)
            
            //高度
            let heightText = CATextLayer()
            heightText.string = String(format: " 穗位高 %.2f", earH)
            heightText.foregroundColor = UIColor.white.cgColor
            heightText.backgroundColor = UIColor.magenta.cgColor
            heightText.fontSize = 14
            heightText.frame = CGRect(x: pred.rect.origin.x, y: pred.rect.origin.y+pred.rect.height, width:100, height:20)
//            view.layer.addSublayer(heightText)
            imageView.layer.addSublayer(heightText)
            instructionLabel.text = "✅  检测完成！  ✅"
//            UIImageWriteToSavedPhotosAlbum(sceneView.snapshot(), nil, nil, nil)
//            UIImageWriteToSavedPhotosAlbum(self.screenshot(), nil, nil, nil)
         
        }
        print("一次检测结束--earHs")
        print(earHs)
        let earHsStr = NSArray(array:earHs).componentsJoined(by: ",")
        writeToFile(content: earHsStr,fileName: "earHs.txt")
        print("earHsStr")
        print(earHsStr)
        
//        UIImageWriteToSavedPhotosAlbum(snapimage, nil, nil, nil)

    }
    func snapshot(of rect: CGRect? = nil) -> UIImage? {
           UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.isOpaque, 0)
           self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
           let fullImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           guard let image = fullImage, let rect = rect else { return fullImage }
           let scale = image.scale
           let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
           guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
           return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
       }
//    func getcurrentMonitorImage() -> UIImage {
//    /// 选择需要截取的区域View
//            guard let monitorUnit = PTUnitManager.unit(for: MonitorUnit.self),
//                  let monitorview = monitorUnit.rtrUnit?.rtrPlayer.unityContainerView else {
//                return UIImage()
//            }
//            /// 获取所在区域的大小
//            let size = monitorview.frame.size
//            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
//            let rect = monitorview.bounds
//            monitorview.drawHierarchy(in: rect, afterScreenUpdates: true)
//            guard let snapshotImage = UIGraphicsGetImageFromCurrentImageContext() else {
//                return UIImage()
//            }
//            UIGraphicsEndImageContext()
//            return snapshotImage
//        }

    func writeToFile(content: String, fileName: String) {

        let contentToAppend = content + "\n"
//        let filePath = NSHomeDirectory() + "/Documents/" + fileName
        let filePath = NSHomeDirectory() + "/Documents/" + fileName
        print("filePath")
        print(filePath)

        //Check if file exists
        if let fileHandle = FileHandle(forWritingAtPath: filePath) {
            //Append to file
            fileHandle.seekToEndOfFile()
            fileHandle.write(contentToAppend.data(using: String.Encoding.utf8)!)
        }
        else {
            //Create new file
            do {
                try contentToAppend.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Error creating \(filePath)")
            }
        }
    }
//    fileprivate func AAA2Dto3D(earPoint: CGPoint) {
//      currentFaceView?.removeFromSuperview()
//    worldCoord————SCNVector3(x: 0.94772834, y: 0.058107182, z: 0.455123) 右手坐标系
//    https://cloud.tencent.com/developer/article/1153997
//      guard let currentFaceFrame = currentFaceView?.frame else { return }
//        _ = CGRect(x: currentFaceFrame.midX, y: currentFaceFrame.minY, width: 0.1, height: 0.1) //竖屏使用正常
  //    let boundingBox = CGRect(x: currentFaceFrame.midX, y: currentFaceFrame.maxY, width: 0.1, height: 0.1)//改为检测框底部高度
  //    let boundingBox = CGRect(x: currentFaceFrame.midY, y: currentFaceFrame.maxX, width: 0.1, height: 0.1)//横屏？

        //      print("fileprivate func AAA2Dto3D()")
        //      print("boundingBox")
        //      print(boundingBox)
        //      print("worldCoord")
        //      print(worldCoord)
        //      print("node")
        //      print(node)
        //      print("node.position")
//        //      print(node.position)
//      calculateHeight()
//
//      addPanGestureRecogniser()
//    }
    
    fileprivate func AAAcalculateHeight() -> Float {
        print()
      guard let squareNode = squareNode,//地面锚点
        let sphereNode = earNode else {
          print("squareNode")
          print(squareNode?.position)//有值Optional(__C.SCNVector3(x: -0.8741591, y: -0.91109097, z: -0.15826747))
          print("sphereNode")
          print(sphereNode?.position)//无值 nil
          return 1222
      }//雌穗锚点
      let distance = sphereNode.position.verticalDistance(endPosition: squareNode.position)
      let distanceString = String(format: "%.2f", distance)
      distanceLabel.text = "Height: \(distanceString)m"
        return distance
    }

    
    
  func createPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
    // Create a SceneKit plane to visualize the node using its position and extent.
    let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
    plane.setAndScaleTexture()
    let planeNode = SCNNode(geometry: plane)
    planeNode.opacity = 0.3
    
    // SCNPlanes are vertically oriented in their local coordinate space.
    // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    planes[anchor] = planeNode
    
    return planeNode
  }
  
  //Start face tracking
  @objc fileprivate func startFaceTracking() {
    guard let frame = self.sceneView.session.currentFrame else {
      print("No frame available")
      return
    }
    
    // Create and rotate image
    let image = CIImage(cvPixelBuffer: frame.capturedImage).rotate
//    let image = CIImage(cvPixelBuffer: frame.capturedImage)
//    let facesRequest = VNDetectFaceRectanglesRequest { request, error in
//      guard error == nil else {
//        print("Face request error: \(error!.localizedDescription)")
        return
      }
//observations人脸检测的全部结果
//      guard let observations = request.results as? [VNFaceObservation] else {
//        print("No face observations")
//        return
//      }
//      self.drawVisionRequestResults(observations)
//    }
    
//    try? VNImageRequestHandler(ciImage: image).perform([facesRequest])
//  }
  
  func drawVisionRequestResults(_ results: [VNFaceObservation]) {
      //此处results对应func startFaceTracking()observations 人脸box
//      print("Number of faces: \(results.count)")
    if results.count == 0 {
//      currentFaceView?.removeFromSuperview()
    }
    //currentFaceView 是UIView
//    guard let face = results.first else { return }//face指检测到的第一个人脸
//    let boundingBox = self.transformBoundingBox(face.boundingBox)
//    didDetectFaceAt(boundingBox: boundingBox)
      for face in results{
          let boundingBox = self.transformBoundingBox(face.boundingBox)
              didDetectFaceAt(boundingBox: boundingBox)
      }
      
  }
  
  fileprivate func didDetectFaceAt(boundingBox: CGRect) {
    if (sphereNode != nil) { return }
    
    drawFrame(around: boundingBox)
    addButton.isHidden = true
    confirmButton.isHidden = false
    instructionLabel.text = "Face detected! Please confirm."
  }
  
  fileprivate func drawFrame(around rect: CGRect) {
//    if let currentView = currentFaceView {
//      currentView.removeFromSuperview()
//    }
    
    let borderView = UIView()
    borderView.frame = CGRect(x: rect.origin.x, y: rect.origin.y - (rect.height / 4), width: rect.width, height: rect.height*1.5)
    
    borderView.backgroundColor = .clear
    borderView.layer.cornerRadius = 10
    borderView.layer.borderColor = UIColor.defaultOrange.cgColor
    borderView.layer.borderWidth = 2.0
    
//    currentFaceView = borderView
    
    view.addSubview(borderView)
  }

    
    


    

  fileprivate func didConfirmFace() {
    instructionLabel.text = "Thanks! Pan up or down to adjust the position!"
//    currentFaceView?.removeFromSuperview()
    
//    guard let currentFaceFrame = currentFaceView?.frame else { return }
//    let boundingBox = CGRect(x: currentFaceFrame.midX, y: currentFaceFrame.minY, width: 0.1, height: 0.1) //竖屏使用正常
//    let boundingBox = CGRect(x: currentFaceFrame.midX, y: currentFaceFrame.maxY, width: 0.1, height: 0.1)//改为检测框底部高度
//    let boundingBox = CGRect(x: currentFaceFrame.midY, y: currentFaceFrame.maxX, width: 0.1, height: 0.1)//横屏？
//    guard let worldCoord = sceneView.determineWorldCoord(boundingBox) else { return } //SCNVector3
    let sphere = SCNSphere(radius: 0.01)
    sphere.firstMaterial?.diffuse.contents = UIColor.defaultOrange
    let node = SCNNode(geometry: sphere)
//    node.position = worldCoord
//      print("fileprivate func didConfirmFace()")
//      print("boundingBox")
//      print(boundingBox)
//      print("worldCoord")
//      print(worldCoord)
//      print("node")
//      print(node)
//      print("node.position")
//      print(node.position)
//      boundingBox
//      (247.34537145495415, 522.1605525277555, 0.1, 0.1)
//      worldCoord
//      SCNVector3(x: 0.94772834, y: 0.058107182, z: 0.455123)
//      node
//      <SCNNode: 0x281590b00 pos(0.947728 0.058107 0.455123) | geometry=<SCNSphere: 0x281cc06c0 | radius=0.010> | no child>
//      node.position
//      SCNVector3(x: 0.94772834, y: 0.058107182, z: 0.455123)
    sceneView.scene.rootNode.addChildNode(node)
    sphereNode = node
    

    calculateHeight()
    
    addPanGestureRecogniser()
  }
  
  fileprivate func calculateHeight() {
    guard let squareNode = squareNode,
      let sphereNode = sphereNode else { return }
    let distance = sphereNode.position.verticalDistance(endPosition: squareNode.position)
    let distanceString = String(format: "%.2f", distance)
    distanceLabel.text = "Height: \(distanceString)m"
    
    if let node = measuringTape {
      node.removeFromParentNode()
    }
    let toVector = SCNVector3Make(sphereNode.position.x, squareNode.position.y, sphereNode.position.z)
    measuringTape = MeasuringTape(parent: sceneView.scene.rootNode, startPoint: sphereNode.position, endPoint: toVector)
    guard let measuringTape = measuringTape else { return }
    sceneView.scene.rootNode.addChildNode(measuringTape)
  }
  
  fileprivate func addPanGestureRecogniser()  {
    panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(didPan(recogniser:)))
    view.addGestureRecognizer(panGestureRecogniser)
  }
  
  @objc fileprivate func didPan(recogniser: UIPanGestureRecognizer) {
    let translation = recogniser.translation(in: view)
    guard let spherePosition = sphereNode?.position else { return }
    sphereNode?.position = SCNVector3Make(spherePosition.x, spherePosition.y - Float(translation.y / 2000), spherePosition.z)
    calculateHeight()
  }
}

// MARK: - ARSCNViewDelegate  渲染
extension ViewController: ARSCNViewDelegate {
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    if shouldPollForFaces {
      DispatchQueue.main.async {
        self.startFaceTracking()//在此
      }
    }
  }
  //  以下为平面检测
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    // This visualization covers only detected planes.
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    
    let planeNode = createPlaneNode(anchor: planeAnchor)
    
    // ARKit owns the node corresponding to the anchor, so make the plane a child node.
    node.addChildNode(planeNode)
    DispatchQueue.main.async {
      self.instructionLabel.text = "Floor detected! Please place a reference point!"
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor,
    let plane = planes[planeAnchor] else { return }
    
    let newPlane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
    newPlane.setAndScaleTexture()
    plane.geometry = newPlane
    plane.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.y)
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    
    // Remove existing plane nodes
    planes[planeAnchor]?.removeFromParentNode()
  }

}
