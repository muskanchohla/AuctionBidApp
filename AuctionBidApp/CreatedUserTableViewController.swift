

import UIKit

class CreatedUserTableViewController: UITableViewController , UINavigationControllerDelegate{

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    var nuserName: String?
    var nuserEmail: String?
    var nuserImage: UIImage?
    var nuserType: String?
        // Define properties for other user data as needed

        override func viewDidLoad() {
            super.viewDidLoad()
            
            userName.text = nuserName
            userEmail.text = nuserEmail
            typeLbl.text = nuserType
            if let image = nuserImage {
                    userImage.image = image
                } else {
                    // If nuserImage is nil, you may want to set a placeholder image or hide the UIImageView
                    userImage.image = UIImage(named: "User Image") // Placeholder image name or nil
                }
            
        }
   
    @IBAction func loginBtn(_ sender: Any) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginTableViewController") as! LoginTableViewController
        navigationController?.pushViewController(loginVC, animated: true)
        self.dismiss(animated: true, completion: nil)
        navigationController?.viewControllers = [loginVC] // for remove back button
    }
    
}
