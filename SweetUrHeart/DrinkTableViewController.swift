//
//  DrinkTableViewController.swift
//  SweetUrHeart
//
//  Created by 陳勁廷 on 2020/2/15.
//  Copyright © 2020 陳勁廷. All rights reserved.
//

import UIKit

class DrankTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sugarPickerView: UIPickerView!
    @IBOutlet weak var iceControl: UISegmentedControl!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var drinkTextField: UITextField!
    @IBOutlet weak var sugerTextField: UITextField!
    @IBOutlet var toolBar: UIToolbar!
    
    var menu = Menu()
    var drinks : [Drinks] = []
    var drinkIndex = 0
    var price = Int()
    var changeData: DrinksInformation?
    
    var tall = ["白糖","砂糖","黑糖","果糖","楓糖","蜂蜜","蔗糖","麥芽糖"]
    
    @IBAction func cancel(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func done(_ sender: Any) {
        view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if changeData != nil{
            
            
            
        }else{
            //載入menu及更新資料
            getTeaMenu()
            updatePriceUI()
            
        }
        
        drinkTextField.inputView = pickerView
        drinkTextField.inputAccessoryView = toolBar
        sugerTextField.inputView = sugarPickerView
        sugerTextField.inputAccessoryView = toolBar
    }
    
    // 將菜單.txt資料讀出
    func getTeaMenu() {
        if let url = Bundle.main.url(forResource: "菜單", withExtension: "txt"), let content = try? String(contentsOf: url) {
            let menuArray = content.components(separatedBy: "\n")  //利用components將換行移除
            for number in 0 ..< menuArray.count {
                if number % 2 == 0 {
                    let name = menuArray[number]
                    if let price = Int(menuArray[number + 1]) {
                        drinks.append(Drinks(name: name, price: price))
                    }else {
                        print("轉型失敗")
                    }
                    
                }
            }
        }
    }
    
    //下方為載入資料的設定
    func updatePriceUI() {
        priceLabel.text = "NT. \(drinks[drinkIndex].price)"
        price = drinks[drinkIndex].price
    }
    
    
    
    // 找出飲料在列表中的index
    func updateDrinksPickerView(name: String) {
        getTeaMenu()
        for (i, drinks) in drinks.enumerated() {
            if drinks.name == name {
                updatePickerUI(row: i)
                break
            }
            print("ok")
        }
    }
    
    //PickerView更新
    func updatePickerUI(row:Int){
        pickerView.selectRow(row, inComponent: 0, animated: true)
        sugarPickerView.selectRow(row, inComponent: 0, animated: true)
        drinkIndex = row
    }
    
    
    //這裡PickerView的設定，將兩個pickerView tag設定為0,1
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
        //回傳顯示幾個類別的pikcer
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return drinks.count
        }else {
            return tall.count
        }
        //回傳顯示飲料名稱數量
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 0 {
            return drinks[row].name
        }else {
            return tall[row]
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0 {
            drinkTextField.text = drinks[row].name
            drinkIndex = row
            updatePriceUI()
        }else {
            sugerTextField.text = tall[row]
        }
    }
    
    
    
    //以下為提示訊息
    func showAlertMessage(title: String, message: String) {
        let inputErrorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert) //產生AlertController
        let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
        inputErrorAlert.addAction(okAction)
        self.present(inputErrorAlert, animated: true, completion: nil)
    }
    
    //確認是否有輸入名字提醒
    func getOrder() {
        guard let name = nameTextField.text, name.count > 0 else{
            return showAlertMessage(title: "名字名字名字名字!",message: "請輸入姓名")
        }
        
        //印出所選的資料內容
        
        menu.name = name
        print("姓名：\(name)")
        
        
        menu.drink = drinks[drinkIndex].name
        print("飲料：\(menu.drink)")
        
        
        menu.sugar = sugerTextField.text!
        print("甜度：\(menu.sugar)")
        
        
        switch iceControl.selectedSegmentIndex {
        case 0:
            menu.ice = .regular
        case 1:
            menu.ice = .moreIce
            
        default:
            break
        }
        print("冰：\(menu.ice.rawValue)")
        
        
        if let price = priceLabel.text {
            let money = (price as NSString).substring(from: 4) //因為顯示時有加上NT. ，所以移除後上傳
            menu.price = money
        }
        print("價格：\(menu.price)")
        
        
    }
    
    
    
    
    
    //以下是sheetDB的部分
    func sendDrinksOrderToServer() {
        
        let url = URL(string: "https://sheetdb.io/api/v1/1wq9vc6704h2l")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let confirmOrder: [String : String] = ["name": menu.name, "drinks": menu.drink, "sugar": menu.sugar, "ice": menu.ice.rawValue, "price": menu.price]
        
        let postData: [String: Any] = ["data" : confirmOrder]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: postData, options: []) //
            let task = URLSession.shared.uploadTask(with: urlRequest, from: data) { (retData, res, err) in
                NotificationCenter.default.post(name: Notification.Name("waitMessage"), object: nil, userInfo: ["message": true])
            }
            task.resume()
        }
        catch{
        }
    }
    
    
    //傳送訂單資料至sheetDB
    @IBAction func confirmButton(_ sender: Any) {
        getOrder()
        sendDrinksOrderToServer()
        print("已新增") //確認資料送出檢查
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
