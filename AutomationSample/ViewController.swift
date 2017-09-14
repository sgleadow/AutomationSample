import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doYourThang() {
        let alert = UIAlertController(
            title: "Shhh...",
            message: "This isn't finished yet",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}













































//var shouldShowTheThang = Toggles.shouldShowTheThang
//
//
//
//button.isHidden = !shouldShowTheThang.enabled

