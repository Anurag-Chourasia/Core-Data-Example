//
//  ViewController.swift
//  CoreDataExample
//
//  Created by Anurag Chourasia on 10/07/23.
//

import UIKit
import Alamofire
import SwiftyJSON

struct Post: Decodable {
    let id: Int
    let title: String
    
    init(json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
    }
}
/*
 struct Post: Decodable: This line declares the Post struct, representing a data model for a response object. The Decodable protocol is adopted, indicating that instances of this struct can be decoded from external representations, such as JSON.
 let id: Int: This line declares a constant property id of type Int within the Post struct. It represents the ID in the response.
 let title: String: This line declares a constant property title of type String within the Post struct. It represents the title in the response.
 init(json: JSON): This is an initializer method for the Post struct that takes a parameter json of type JSON. This initializer allows creating a Post instance from a JSON object.
 id = json["id"].intValue: This line assigns the value of the "id" key from the json object to the id property of the Post instance. It uses the intValue property of the JSON object to extract the value as an Int.
 title = json["title"].stringValue: This line assigns the value of the "title" key from the json object to the title property of the Post instance. It uses the stringValue property of the JSON object to extract the value as a String.
 */

class ViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loadTableFromApiButton: UIButton!
    @IBOutlet weak var loadTableFromCoreDataButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    /*
     * titleLabel outlet is created to change the name at the top of the App which displays from where tableview is reload data.
     * loadTableFromApiButton and loadTableFromCoreDataButton outlet is created to give corner radius programmatically.
     * topView outlet is created to give shadow at the bottom of the outlet.
     * tableView is created so that it's cells can display names[title].
     */
    
    //MARK: - Variables
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    var dictionary: [Int:String] = [:]
    /*
     * context is a constant created to access persistentContainer and use it to save and display data from coredata frame work.
     * dictionary is a variable created to get dictionary from the api response and use to display data in cells of tableview.
     */
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        titleLabel.text = "Load Data"
        
        topView.addBottomShadow()
        
        loadTableFromApiButton.layer.cornerRadius = 5
        loadTableFromCoreDataButton.layer.cornerRadius = 5
        
        makeAPIRequest(){ [weak self]result in
            if result != nil {
                self?.dictionary = result!
                for (id,title) in self?.dictionary ?? [:]{
                    self?.saveDataToCoreData(id: id, title: title)
                }
                
            }else{
                print("Dictionary is nil")
            }
        }
        
    }
    /*
     * viewDidLoad is a view life cycle which sets setNavigationBarHidden equals true and assign tableview delegate and data source to self, it also sets tableview separatorstyle to none so that custom separators can be used(Maybe),it sets titleLabel text to Load Data, it adds bottom shadow to topView, it gives corner radius to loadTableFromApiButton and loadTableFromCoreDataButton and at last makes the API Request to get dictionary as a response and on success full completion it saves dictionary to core data.
     */
    //MARK: - IBActions
    @IBAction func loadTableFromApi(_ sender: UIButton) {
        titleLabel.text = "Api Data"
        makeAPIRequest(){ [weak self]result in
            if result != nil {
                self?.dictionary = result!
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            }else{
                print("Dictionary is nil")
                //alert
            }
        }
    }
    /*
     * loadTableFromApi is a IBAction created to set titleLabel text to API Data and make api request to get dictioanry as a result and reload tableview data on successful completion.
     */
    
    @IBAction func loadTableFromCoreData(_ sender: UIButton){
        titleLabel.text = "Core Data"
        fetchDataFromCoreData()
        
    }
    /*
     * loadTableFromCoreData is a IBAction created to set titleLabel text to Core Data and fetch data from the core data which exist.
     */
    
    //MARK: - Functions


    func makeAPIRequest(completion: @escaping ([Int:String]?)->(Void)) {
        let apiUrl = "https://jsonplaceholder.typicode.com/posts"
        var dictionaryOfIdAndTitle: [Int: String] = [:]
        AF.request(apiUrl).responseDecodable(of: [Post].self) { response in
            switch response.result {
            case .success(let posts):
                for post in posts {
                    let id = post.id
                    let title = post.title
                    dictionaryOfIdAndTitle[id] = title
                }
                completion(dictionaryOfIdAndTitle)
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion(nil)
            }
        }
    }
    /*
     The function declaration specifies a completion closure as a parameter. The closure takes an optional dictionary of type [Int: String] (representing an ID and title mapping) as its argument and returns Void (indicating no return value).
     The apiUrl constant stores the URL of the API endpoint, in this case, "https://jsonplaceholder.typicode.com/posts".
     A dictionary named dictionaryOfIdAndTitle is initialized to an empty state. This dictionary will hold the mapping of ID and title retrieved from the API response.
     The AF.request(apiUrl) line initiates a network request using Alamofire library, passing the API URL. Alamofire provides convenience methods for performing network requests and handling responses.
     The .responseDecodable(of: [Post].self) method is used to handle the response of the API request. It specifies that the response should be decoded into an array of Post objects. The [Post].self syntax indicates the expected type of the response body.
     Inside the closure associated with the response, the switch response.result statement handles the success and failure cases.
     If the response is successful, the posts array is accessed and iterated through using a for loop. For each post, the ID and title properties are extracted. Then, the ID and title are added as a key-value pair to the dictionaryOfIdAndTitle dictionary.
     After iterating through all the posts, the completion closure is called with the populated dictionaryOfIdAndTitle.
     In case of a failure response, the associated error is printed to the console, and the completion closure is called with a nil value to indicate the failure.

     */
    
    func saveDataToCoreData(id: Int, title: String){
        let newItem = IdAndTitle(context: context!)
        newItem.id = Int16(id)
        newItem.title = title
        do{
            try context?.save()
        }catch{
            //alert
        }
    }
    /*
     saveDataToCoreData(id: Int, title: String): This function is responsible for saving data to Core Data. It takes an id of type Int and a title of type String as parameters. It creates a new instance of the IdAndTitle entity in the Core Data context and sets the id and title properties based on the provided parameters. Finally, it attempts to save the context.
     */
    func fetchDataFromCoreData(){
        do{
            let items = try context?.fetch(IdAndTitle.fetchRequest())
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }catch{
            //alert
        }
        
    }
    /*
     fetchDataFromCoreData(): This function fetches data from Core Data. It retrieves all instances of the IdAndTitle entity using a fetch request and assigns the result to the items variable. After that, it asynchronously reloads the data in a table view. Any errors that occur during the fetch process are caught and handled with an alert.
     */
    
    func fetchDataFromApi(){
        makeAPIRequest(){dictionary in
            if dictionary != nil{
                print(dictionary ?? [:])
            }else{
                print("Dictionary is nil")
            }
        }
    }
    /*
     fetchDataFromApi(): This function makes an API request to retrieve data. It calls the makeAPIRequest() function, which likely performs the actual networking and parsing logic. The result is passed as a dictionary to the completion closure. If the dictionary is not nil, it is printed to the console. Otherwise, a message "Dictionary is nil" is printed.
     */
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    /*
     extension of a view controller that adopts the UITableViewDelegate and UITableViewDataSource protocols. This extension contains implementations for the required delegate and data source methods to populate a table view with data from a dictionary
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !dictionary.isEmpty{
            return dictionary.count
        }
        return 0
        
    }
    /*
     tableView(_:numberOfRowsInSection:) method: This method determines the number of rows to be displayed in the table view. If the dictionary is not empty, it returns the count of items in the dictionary. Otherwise, it returns 0 to indicate that there are no rows to display.
     */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! cell
        cell.selectionStyle = .none
        if !dictionary.isEmpty{
            let title = dictionary[indexPath.row+1]
            
            DispatchQueue.main.async {
                cell.titleLabel.text = title
                
                cell.containerView.layer.cornerRadius = 3
                
                cell.containerView.addShadowToCell()
            }
            
            
        }
        return cell
    }
    /*
     tableView(_:cellForRowAt:) method: This method is responsible for configuring and returning a cell for a given index path in the table view. It dequeues a reusable cell with the identifier "cell" from the table view, assuming the custom cell class is named "cell".
     After dequeuing the cell, the selectionStyle property is set to .none to remove the default cell selection style.
     If the dictionary is not empty, the method proceeds to retrieve the corresponding title from the dictionary based on the current row index (indexPath.row). The indexPath.row+1 is used as the key to access the dictionary since the code assumes the dictionary uses 1-based indexing for IDs.
     Inside a DispatchQueue.main.async block, the cell's titleLabel is set to the retrieved title, and additional UI styling is applied. For example, the containerView is given a corner radius of 3, and the addShadowToCell() method (presumably an extension method) is called to add a shadow effect to the cell.
     Finally, the configured cell is returned for display in the table view.
     */
}

class cell: UITableViewCell{
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
}
/*
 cell class: This class represents a custom cell used in the table view. It includes two IBOutlet properties: containerView, which presumably represents a container view within the cell, and titleLabel, which represents a label for displaying the title. The weak keyword indicates that the outlets are weak references to avoid creating strong reference cycles.
 */

extension UIView {
    /*
     extension UIView: This extension adds two methods to UIView to apply shadow effects to views.
     */
    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 4
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0 , height: 2)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: bounds.maxY - layer.shadowRadius,
                                                     width: bounds.width,
                                                     height: layer.shadowRadius)).cgPath
    }
    /*
     addBottomShadow() method: This method configures the layer properties of the view to create a shadow effect at the bottom. It sets the masksToBounds property to false to allow the shadow to be visible outside the bounds of the view. It defines the shadow properties such as shadowRadius, shadowOpacity, shadowColor, shadowOffset, and shadowPath to achieve the desired shadow appearance.
     */
    func addShadowToCell(){
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1.0
        layer.shadowOffset = CGSizeMake(0.0, 1.0)
        ///1,1 will give bottom shadow and tailing shadow more
        ///0,0 will give less shadow all side
        ///1,0 will give shadow at trailing more leading less
        ///0,1 will give shadow at bottom more top less
    }
    /*
    addShadowToCell() method: This method configures the layer properties of the view to add a shadow effect, presumably used specifically for cells. It sets the shadowColor, shadowOpacity, shadowRadius, and shadowOffset properties to define the appearance of the shadow for the view.
     */
}

