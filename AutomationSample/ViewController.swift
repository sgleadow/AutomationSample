import UIKit

class ViewController: UIViewController {

    let shouldShowTheThang = Toggles.shouldShowTheThang
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.isHidden = !shouldShowTheThang.enabled
    }
    
    @IBAction func doYourThang() {
        self.show()
    }
    
    func show() {
        let alert = UIAlertController(
            title: "Shhh...",
            message: "This isn't finished yet",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
