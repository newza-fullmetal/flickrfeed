
import UIKit

class ViewController: UIViewController {
    //below are arrays that save all the images related to the keyword
    //so that we can show them later when the Next button is pressed
    var photoArray2: AnyObject!=[String: AnyObject]() as AnyObject
    
    
    var counter=0;
    
    var flickrcontroller=FlickrController()
    var actualimage : Image? = nil
    
    @IBOutlet weak var mainImg: UIImageView!
    
    
    @IBOutlet weak var searchText: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!

    
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var ShareButton: UIButton!
    
    @IBOutlet weak var browserview: UIButton!
    
    
    @IBOutlet weak var savebtn: UIButton!
    
    
    /**
        Share the image throw classical apps
     */
    @IBAction func ShareAction(_ sender: Any) {
        if actualimage != nil{
            let imagetoshare : Any = self.mainImg.image!
            let activityViewController = UIActivityViewController(
                activityItems: [imagetoshare],
                applicationActivities: nil)
//            if let popoverPresentationController = activityViewController.popoverPresentationController {
//                popoverPresentationController.barButtonItem = (sender as! UIBarButtonItem)
//            }
            activityViewController.popoverPresentationController?.sourceView = self.view
            present(activityViewController, animated: true, completion: nil)
        }
        else{
            print("nothing to share")
        }
    }
    
    /**
     Save the actual image to the galery
    */
    @IBAction func SaveinlocalAction(_ sender: Any) {
        print("FUNCTION : SaveinlocalAction")
        if let uiimage = self.mainImg.image {

            UIImageWriteToSavedPhotosAlbum(uiimage, nil, nil, nil)
            
            let alert = UIAlertView(title: "GG !!!",
                                    message: "Your image has been saved to Photo Library!",
                                    delegate: nil,
                                    cancelButtonTitle: "Ok")
            alert.show()
            
        }
        
    }
    
    /**
        It opens the actual image url in the browser of the device
    */
    @IBAction func OpenBrowserAction(_ sender: Any) {
        if self.actualimage != nil {
            UIApplication.shared.openURL((self.actualimage?.url)!)
        }
    }
    
    /**
        Call the **FlickrController** to perform a research action by sending the tags given
    */
    @IBAction func searchAction(_ sender: Any) {
        let word:String! = searchText.text
        let image = self.flickrcontroller.searchAction(tag: word)
        if image != nil {
            print("image received : ")
            print (image!)
            updateImg(image: image!)
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
    
    
    
    /**
        Select the next image if we have already one 
    */
    @IBAction func NextImg(_ sender: Any) {
        if self.actualimage != nil {
        let image = flickrcontroller.nextImage(actualImg: self.actualimage!)
            print("image received : ")
            print (image)
            updateImg(image: image)
        }
        
    
    }


    /**
        Upadate the image displayed
    */
    func updateImg (image : Image!){
        if let imageData = NSData(contentsOf: (image.url)){
            DispatchQueue.main.async(execute: {
                self.mainImg.image = UIImage(data: imageData as Data)
                self.titleLabel.text = image.Title
            })
            self.actualimage = image
        } else {
            print("Image does not exist at \(String(describing: image.url)))")
        }
    }
    
}

