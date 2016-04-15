//
//  ViewController.swift
//  PDFTest
//
//  Created by KraferdMBP31 on 11/3/15.
//  Copyright © 2015 Kraferd Inc. All rights reserved.
//

import UIKit;

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var pdfView: UIView!;
    var documentRef : CGPDFDocumentRef?;
    var pageRef : CGPDFPageRef?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view, typically from a nib.
        
        // Create a CA Tiled Layer
        let tiledLayer : CATiledLayer = CATiledLayer();
        
        // Set the tiledLayer delegate
        tiledLayer.delegate = self;
        
        // Set Tile Size
        tiledLayer.tileSize = CGSizeMake(2048, 2048);
        
        // Detail Level
        tiledLayer.levelsOfDetail = 1000;
        tiledLayer.levelsOfDetailBias = 1000;
        
        let pageRect : CGRect = CGRectIntegral(CGPDFPageGetBoxRect(pageRef, .CropBox));
        tiledLayer.frame = pageRect;
        
        pdfView = UIView(frame: pageRect);
        pdfView.layer.addSublayer(tiledLayer);
        
        let offsetX : CGFloat = ((pdfView.frame.size.width - self.view.frame.size.width) / 2);
        let offsetY : CGFloat = ((pdfView.frame.size.height - self.view.frame.size.height) / 2);
        self.view = UIScrollView();
        let scrollView : UIScrollView = self.view as! UIScrollView;
        
        scrollView.contentOffset = CGPointMake(offsetX, offsetY);
        scrollView.minimumZoomScale = scrollView.zoomScale / (pdfView.frame.size.height / self.view.frame.size.width);
        scrollView.contentSize = pageRect.size;
        scrollView.maximumZoomScale = 1000;
        
        scrollView.delegate = self;
        
        self.view.addSubview(pdfView);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        let path : String = NSBundle.mainBundle().pathForResource("test", ofType: "pdf")!;
        let pdfURL : NSURL = NSURL.fileURLWithPath(path);
        documentRef = CGPDFDocumentCreateWithURL(pdfURL);
        pageRef = CGPDFDocumentGetPage(documentRef, 1);
    }
    
    override func drawLayer(layer: CALayer, inContext context: CGContext) {
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextFillRect(context, CGContextGetClipBoundingBox(context));
        CGContextTranslateCTM(context, 0.0, layer.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(pageRef, .CropBox, layer.bounds, 0, true));
        CGContextDrawPDFPage(context, pageRef);
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return pdfView;
    }
}

