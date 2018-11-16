//
//  CryptoSearchController.swift
//  CryptoTracker
//
//  Created by Julio Rosario on 11/8/18.
//  Copyright © 2018 Julio Rosario. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import Alamofire
import SwiftyJSON
import ChameleonFramework
import Firebase
import FirebaseFirestore
import CoreData

/*
 
 Note:
 Download images and check which images you are missing
 */

class CryptoSearchController: UITableViewController,UISearchBarDelegate {
    
    //Static properties
    static let context =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var cryptocurrencies = [Cryptocurrency]()
    
    var display: [Cryptocurrency] = [Cryptocurrency]()
    var priceUpdate: Date = Date()
    var selectedIndex = 0
    var countImages = 0
    var countPrices = 0
   
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.flatBlue()
        
        //SVProgressHUD.show()
        downloadCryptocurrencies()
        //test3()
        
      // downloadTradingCryptosAndUploadToDB()
    }
    
    func test3(){
        DispatchQueue.global(qos: .background).async {
            while self.countPrices < 2509{}
            
            let db = Firestore.firestore()
            let settings = db.settings
            settings.areTimestampsInSnapshotsEnabled = true
            db.settings = settings
            let cryptoRef =  db.collection("Cryptocurrencies")
            
            var notFound = 0
            for value in self.cryptocurrencies {
                if value.price == nil {
                    cryptoRef.document(value.name).delete(completion: { (error) in
                        if error != nil {
                            print(error.debugDescription)
                        }else {
                            print("Done!")
                        }
                        notFound += 1
                        print("not Found \(notFound)")
                    })
                }
            }
          
        }
    }
    
    func test2(){
        
        //Download images and upload to storage
        DispatchQueue.global(qos: .background).async {
            
            while self.cryptocurrencies.count < 1415 {
                print(self.cryptocurrencies.count)
            }
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            for i  in 0...self.cryptocurrencies.count-1 {
                
                let imageRef = storageRef.child("images/" + self.cryptocurrencies[i].name + ".jpg")
                imageRef.putData(self.cryptocurrencies[i].imageData, metadata: nil, completion: { (metadata, error) in
                    if(error != nil){
                        print(error.debugDescription)
                    } else {
                        self.countImages += 1
                        print(self.countImages)
                    }
                })
            }
        }
    }
    
    func downloadTradingCryptosAndUploadToDB(){
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        let cryptoRef =  db.collection("Cryptocurrencies")
        
        //Download available cryptocurrencies and save to firebase
        Utilities.getJsonRequest(url: CryptoCompare.coinListUrl, parameters: [:]) { (json) in
            
            let data = json["Data"]
            for value in data {
                
                if  value.1["IsTrading"].boolValue {
                    
                    let crypto    = Cryptocurrency()
                    crypto.symbol = value.1["Symbol"].stringValue
                    crypto.name   = value.1["Name"].stringValue
                    crypto.id     =  value.1["Id"].stringValue
                    crypto.imageUrl = CryptoCompare.baseUrl +  value.1[value.0]["ImageUrl"].stringValue
                    
                    let cryptData = ["name":crypto.name,
                                "symbol": crypto.symbol,
                                "id": crypto.id,
                                "imageUrl": crypto.imageUrl]
                    
                    cryptoRef.document(crypto.name).setData(cryptData, completion: { (error) in
                        if error != nil {
                            print(error.debugDescription)
                        } else {
                            print("Done!")
                        }
                    })
                }
            }
         }
       }
    
     //MARK: Firebase methods
    //------------------------------------------------------------------------------------------\\
    func downloadCryptocurrencies(){
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let cryptoRef =  db.collection("Cryptocurrencies")
        cryptoRef.getDocuments { (result, error) in
            
            if error != nil {
                print(error.debugDescription)
            } else {
                for document in result!.documents {
                    
                    let data =  document.data() as! [String: String]
                    
                    let crypto    = Cryptocurrency()
                    crypto.name   = data["name"]!
                    crypto.symbol = data["symbol"]!
                    crypto.id     = data["id"]!
                    crypto.imageUrl = data["imageUrl"]!
                    self.cryptocurrencies.append(crypto)
                }
                
                self.cryptocurrencies.sort(by:{$0.symbol < $1.symbol})
                
                print(self.cryptocurrencies.count)
                
               // self.downloadImages()
                
              /*  if !self.imagesLoaded()  {
                    print("Downloading images")
                     self.downloadImages()
                }*/
                // self.downloadPrices(start: 0,end: 60)
            }
        }
    }
    
    func containsLetters(input: String) -> Bool {
        for chr in input {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                return false
            }
        }
        return true
    }
    
    func downloadImages(){
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        for i  in 0...cryptocurrencies.count-1 {
            
            let imageRef = storageRef.child("images/" + cryptocurrencies[i].name + ".jpg")
            imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                
                if error != nil {
                    /*let url = URL(string: self.cryptocurrencies[i].imageUrl)
                    do {
                        let data =  try Data(contentsOf: url!)
                        let storage = Storage.storage()
                        let storageRef = storage.reference()
                        
                        let imageRef = storageRef.child("images/" + self.cryptocurrencies[i].name + ".jpg")
                        imageRef.putData(data, metadata: nil, completion: { (metadata, error) in
                            if(error != nil){
                                print(error.debugDescription)
                            } else {
                                self.countImages += 1
                                print(self.countImages)
                            }
                        })
                        
                    }catch {
                        print("Unable to dowload image!")
                    }*/
                    print(error.debugDescription)
                } else {
                    self.cryptocurrencies[i].imageData = data!
                    self.countImages += 1
                    print(self.countImages)
                }
            }
        }
      //  queueForPriceAndImage()
    }
    
    func queueForPriceAndImage(){
        
        //Wait for all images to be download
        DispatchQueue.global(qos: .background).async {
            
            var finish = false
            repeat {
                for value in self.cryptocurrencies {
                    if value.imageData == nil || value.price == nil{
                        finish = true
                        break
                    }
                }
                
                if finish {
                    finish = false
                } else {
                    finish = true
                }
                
            }while !finish
            
            //Show tableView
            self.display = self.cryptocurrencies
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
            }
            
             //Save data to core data if it hasn't been save
            if self.loadImages(key: self.cryptocurrencies[0].name).count == 0 {
                var images = [ImageData]()
                for value in self.cryptocurrencies {
                    let img = ImageData(context: CryptoSearchController.context)
                    img.data = value.imageData
                    img.id = value.name
                    images.append(contentsOf: images)
                }
                CryptoSearchController.saveData()
            }
         
        }
    }
    
    //MARK: Core Data methods
    //-----------------------------------------------------------------------------------------------\\
    
    func imagesLoaded()->Bool {
        
        var loaded = true
        for i in 0...self.cryptocurrencies.count-1 {
            
            let img =  self.loadImages(key: self.cryptocurrencies[i].name)
            if img.count == 0 {
                loaded = false
                break
            } else {
                self.cryptocurrencies[i].imageData = img[0].data
            }
        }
        return loaded
    }
    
    static func saveData(){
        do {
            try CryptoSearchController.context.save()
            print("Data Save!")
        }
        catch {
            
            print("Error saving Context \(error)")
        }
    }
    
    
    func loadImages(key: String)->[ImageData] {
        
        let request: NSFetchRequest<ImageData> = ImageData.fetchRequest()
        let predicate = NSPredicate(format:"id ==%@" , key)
        request.predicate = predicate
        
        var temp: [ImageData] = [ImageData]()
        do {
            temp = try CryptoSearchController.context.fetch(request)
        }catch {
            print("Error getting available cryptocurrencies \(error)")
        }
        return temp
    }
    
    //MARK: JSON methods
    //--------------------------------------------------------------------------------------\\
    func downloadPrices(start: Int, end: Int){
        
        //Load data to display into the table
        let request = CryptoCompare.priceRequest(for: cryptocurrencies,start: start, end: end)
        let url     = CryptoCompare.multiPriceUrl
        
        Utilities.getJsonRequest(url: url,parameters: request) {(json) in
            self.getPrices(json: json, start: start, end: end)
        }
        
        //In the background Keep adding data to prices
        if end < cryptocurrencies.count {
            
            if end + 60 < cryptocurrencies.count {
                self.downloadPrices(start: end, end: end + 60)
            } else {
                print("Loading All Data")
                self.downloadPrices(start: end,end: cryptocurrencies.count)
            }
        } else {
            print("Finish making request for all prices")
        }
    }
    
    func getPrices(json: JSON, start: Int, end: Int) {
        
        let data = json["RAW"]
        for value in data {
            
            let found = doBinarySearch(crypto: cryptocurrencies,
                                       start: start,
                                       end: end,
                                       key: value.0)
            
            if found != -1 {
                let price = CryptoSearchController.parsePrice(raw: value.1[CryptoCompare.market])
                cryptocurrencies[found].price = price
                countPrices += 1
                print("Price : \(countPrices)")
            }
        }
    }
    
    func doBinarySearch(crypto: [Cryptocurrency], start: Int, end: Int, key: String)->Int {
      
        var left = start
        var right = end
        var found = -1
        
        while left <= right  && found == -1 {
            
            let mid = (left + right)/2
            
            if crypto[mid].symbol == key {
                found = mid
            } else if crypto[mid].symbol < key {
                left = mid + 1
            } else if crypto[mid].symbol > key {
                right = mid - 1
            }
        }
        return found
    }
    
    static func parsePrice(raw: JSON) -> Price {
        
        let price = Price()
        price.price        = raw["PRICE"].doubleValue.rounded(places: 2)
        price.supply       = raw["SUPPLY"].doubleValue
        price.highDay      = raw["HIGHDAY"].doubleValue
        price.lowDay       = raw["LOWDAY"].doubleValue
        price.volume24H    = raw["TOTALVOLUME24HTO"].doubleValue
        price.marketCap    = raw["MKTCAP"].doubleValue
        price.change24H    = raw["CHANGEPCT24HOUR"].doubleValue
        
        return price
    }
    
    
    
    //MARK: tableView methods
    //-------------------------------------------------------------------------------------------\\
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchViewCell
        cell.backgroundColor = UIColor.flatBlue()
        
        //Set the name
        let name = display[indexPath.row].name
        cell.name.text = name
        cell.name.textColor = UIColor.white
        
        //Set the symbol
        cell.symbol.text = display[indexPath.row].symbol
        cell.symbol.textColor = UIColor.lightGray
        
        //Set the price
        cell.price.text  = "  $"  + String(display[indexPath.row].price.price) + "  "
        
        //Check if it is increasing or decreasing and set color
        if display[indexPath.row].price.change24H < 0 {
            cell.price.textColor = UIColor.red
            cell.price?.layer.backgroundColor = UIColor(hexString: "#ffdbd8")?.cgColor
        } else {
            cell.price.textColor = UIColor(hexString: "#0cb23b")
            cell.price?.layer.backgroundColor = UIColor(hexString: "#d8ffe3")?.cgColor
        }
        
        cell.price?.layer.cornerRadius = CGFloat(cell.price.frame.height * 0.50)
        cell.price?.layer.masksToBounds = true
        cell.price?.clipsToBounds = true
        
        //Set the symbol image
        cell.img.image =  UIImage(data: display[indexPath.row].imageData)!.resize(width: 40,height: 40)
        
        //Set the color of favorite image
        cell.favorite.image          =  cell.favorite.image?.withRenderingMode(.alwaysTemplate)
        if (display[indexPath.row].favorite) {
            cell.favorite.image     =  cell.favorite.image?.withRenderingMode(.alwaysTemplate)
            cell.favorite.tintColor = UIColor.flatRed()
        } else {
            cell.favorite.tintColor = UIColor.flatWhiteColorDark()?.lighten(byPercentage: 2)
        }
        
        return cell
    }
    
    
    //Mark - Specify the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return display.count
    }
    
    //Mark - Specify what happend when a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       selectedIndex =  indexPath.row
        performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
    //Mark: Search methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            display = cryptocurrencies
        }
        else {
            
            //If searchText is equal than set it to display
            display = cryptocurrencies.filter{($0.name.lowercased() == searchText.lowercased())}
            
            //If there are no elements, get elements that cointain searchText
            if display.count <= 0 {
                display = cryptocurrencies.filter { ($0.name.lowercased().contains(searchText.lowercased())) }
            }
            
            //Sort the cryptosx
            display.sort(by: { $0.name > $1.name })
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetail" {
            let destination = segue.destination as! CryptoInfoController
            destination.crypto = cryptocurrencies[selectedIndex]
            searchBar.text = ""
            display = cryptocurrencies
            self.tableView.reloadData()
            
        }
    }
    
}
