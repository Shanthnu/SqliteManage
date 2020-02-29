//
//  ViewController.swift
//  SQliteTest
//
//  Created by Shanth L on 10/04/18.
//  Copyright © 2018 Shanth L. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         //Create all table
        MySQL.CreateALLTables()
        
        //use this for insert data
        MySQL.InsertData(Tblname: TBL_USER, Columns: [USER_COLUMNS.user_name.rawValue,USER_COLUMNS.user_age.rawValue,USER_COLUMNS.user_email.rawValue,USER_COLUMNS.user_phone.rawValue], Values : ["Shanth S",18,"shanthu7318@gmail.com","8870404864"], DataTypes : [TYPE_TEXT,TYPE_INT,TYPE_TEXT,TYPE_TEXT]) { (status, MSG) in
            if status {
                print("Sucess \(MSG)")
            }else{
                print("Failed \(MSG)")
            }
        }
        
         //use this for Select data
        MySQL.SelectData(Tblname: TBL_USER, ColumnNames: [], SelectALL: true, AscendORDescendOrder: ASEND_DESEND_TYPE.DESC.rawValue, AscendorDescendColunmName: USER_COLUMNS.user_id.rawValue) { (status, MSG,  dic_result) in
                        print(MSG)
                        print(dic_result)
        }
        
        
        //here we update id value 1 please check before the data is there or not
        MySQL.UpdateData(Tblname: TBL_USER, Columns: [USER_COLUMNS.user_name.rawValue,USER_COLUMNS.user_age.rawValue], Values: ["Shanth L",22], UpdateIDKey: USER_COLUMNS.user_id.rawValue, UpdateIDValue: "1", DataTypes: [TYPE_TEXT,TYPE_INT]) { (status, MSG) in
            if status {
                print("Sucess \(MSG)")
            }else{
                print("Failed \(MSG)")
            }
        }

        //use this for Select data
        MySQL.SelectData(Tblname: TBL_USER, ColumnNames: [], SelectALL: true, AscendORDescendOrder: ASEND_DESEND_TYPE.DESC.rawValue, AscendorDescendColunmName: USER_COLUMNS.user_id.rawValue) { (status, MSG,  dic_result) in
            print(MSG)
            print(dic_result)
        }

        
        //use this for Delete single data
        MySQL.DeleteSingleRow(Tblname: TBL_USER, Columname: USER_COLUMNS.user_email.rawValue, Value: "shanthu7318@gmail.com") { (status, MSG) in
            print(MSG)
        }

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

