//
//  MySQLManger.swift
//  SQliteTest
//
//  Created by Shanth L on 10/04/18.
//  Copyright © 2018 Shanth L. All rights reserved.
//

import UIKit
import SQLite3

// MARK:  - This class for sqlite management

public let TYPE_INT    = "integer"
public let TYPE_TEXT   = "text"

public let MySQL = MySQLManger.sharedInstance
public let DB_NAME     = "Library"
public let TBL_USER    = "LIB_USERS"
public let TBL_BOOKS   = "LIB_BOOKS"


internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

public enum USER_COLUMNS : String {
    case user_id    = "user_id"
    case user_name  = "user_name"
    case user_email = "user_email"
    case user_age   = "user_age"
    case user_phone = "user_phone"
}

public enum ASEND_DESEND_TYPE : String {
    case DESC       = "desc"
    case AESC       = "asc"
}
open class MySQLManger: NSObject {
    
    static let sharedInstance = MySQLManger()

    // MARK:  - This class connect Database
    func DBConnect() -> OpaquePointer {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("\(DB_NAME).sqlite")
        print("DB connected fileURL --- \(fileURL)")

        // open database
        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }else{
            print("DB connected")
        }
        return db!
    }
    
    
    // MARK:  - Create tables which is we using on database
    func CreateALLTables() -> Void {
        
        var statementChk: OpaquePointer?
        sqlite3_prepare_v2(DBConnect(), "SELECT * FROM \(TBL_USER)", -1, &statementChk, nil);
        var boo = false
        if (sqlite3_step(statementChk) == SQLITE_ROW) {
            boo = true
        }
        sqlite3_finalize(statementChk);
        if !boo {
            if sqlite3_exec(DBConnect(), "create table if not exists \(TBL_USER) (user_id integer primary key autoincrement, user_name text, user_age integer, user_email text, user_phone text)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(DBConnect())!)
                print("error creating table: \(errmsg)")
            }else{
                print("\(TBL_USER) table created")
            }
        }else{
            print("\(TBL_USER) table Already Exists")
        }
    }
    
    // MARK:  - Insert a data on table
    func InsertData(Tblname: String, Columns : NSArray,  Values : NSArray,  DataTypes : NSArray,  CompletionHandler: (_ Status: Bool ,_ MSG : String) -> ()) -> Void {
        var statement: OpaquePointer?
        
        var str_Values = ""
        for i in 0..<Columns.count {
            DataTypes.object(at: i) as! String != TYPE_INT ? str_Values.append("'\(Values.object(at: i))',") : str_Values.append("\(Values.object(at: i)),")
        }
        str_Values.removeLast()
        print("insert into \(Tblname) (\(Columns.componentsJoined(by: ","))) values (\(str_Values))")
        if sqlite3_prepare_v2(DBConnect(), "insert into \(Tblname) (\(Columns.componentsJoined(by: ","))) values (\(str_Values))", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(DBConnect())!)
            print("error preparing insert: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 1, "foo", -1, SQLITE_TRANSIENT) != SQLITE_OK { //SQLITE_TRANSIENT
            let errmsg = String(cString: sqlite3_errmsg(DBConnect())!)
            print("failure binding foo: \(errmsg)")
            CompletionHandler(false,"failure inserting foo: \(errmsg)")
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(DBConnect())!)
            print("failure inserting foo: \(errmsg)")
            CompletionHandler(false,"failure inserting foo: \(errmsg)")
        }else{
            print("inserted successfully")
            CompletionHandler(true,"inserted successfully")
        }
        
    }

    // MARK:  - Update a data on table
    func UpdateData(Tblname: String, Columns : NSArray,  Values : NSArray, UpdateIDKey : String , UpdateIDValue : String,  DataTypes : NSArray,  CompletionHandler: (_ Status: Bool ,_ MSG : String) -> ()) -> Void {
        var statement: OpaquePointer?

        var str_qry = "set "
        for i in 0..<Columns.count {
            let str_Value = DataTypes.object(at: i) as! String != TYPE_INT ? "'\(Values.object(at: i))'," : "\(Values.object(at: i)),"
            str_qry = "\(str_qry) \(Columns.object(at: i)) = \(str_Value)"
        }
        str_qry.removeLast()
        str_qry.append(" WHERE \(UpdateIDKey) = \(UpdateIDValue)")
        //UPDATE Student SET NAME = 'PRATIK', ADDRESS = 'SIKKIM' WHERE ROLL_NO = 1;
        
        print("update \(Tblname) \(str_qry)")

        if sqlite3_prepare_v2(DBConnect(), "update \(Tblname) \(str_qry)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(DBConnect())!)
            print("error preparing insert: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 1, "foo", -1, SQLITE_TRANSIENT) != SQLITE_OK { //SQLITE_TRANSIENT
            let errmsg = String(cString: sqlite3_errmsg(DBConnect())!)
            print("update failure binding foo: \(errmsg)")
            CompletionHandler(false,"failure inserting foo: \(errmsg)")
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(DBConnect())!)
            print("failure update foo: \(errmsg)")
            CompletionHandler(false,"failure update foo: \(errmsg)")
        }else{
            print("updated successfully")
            CompletionHandler(true,"updated successfully")
        }
        
    }
    
    // MARK:  - Select a data on table
    // MARK:  :- AscendORDescendOrder - 1 = ascending , 2 = descending , 3 = none
    func SelectData(Tblname: String, ColumnNames : NSArray, SelectALL : Bool, AscendORDescendOrder: String , AscendorDescendColunmName: String ,  CompletionHandler: (_ Status: Bool ,_ MSG : String , _ Result : NSMutableArray) -> ()) -> Void {
        var statement: OpaquePointer?
        let selectcolumn = SelectALL ? "*" : ColumnNames.componentsJoined(by: ",")
        let selectQry = "select \(selectcolumn) from \(Tblname) \(AscendorDescendColunmName == "" ? "" : "order by \(AscendorDescendColunmName) \(AscendORDescendOrder)") "
        print(selectQry)
        if sqlite3_prepare_v2(DBConnect(), selectQry, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(DBConnect())!)
            print("error preparing select: \(errmsg)")
            CompletionHandler(false, errmsg, [])
        }
        
        let arrResult = NSMutableArray()
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let dic_row = NSMutableDictionary()
            for i in 0..<sqlite3_column_count(statement){
                var Name = ""
                var Value = ""
                if let cString = sqlite3_column_name(statement, i) {
                    Name = String(cString: cString)
                    print("name = \(Name)")
                }else{
                    print("name not found")
                }
                
                if let cString = sqlite3_column_text(statement, i) {
                    Value = String(cString: cString)
                    print("name = \(Value)")
                } else {
                    print("Value not found")
                }
                dic_row .setValue(Value, forKey: Name)
            }
            arrResult .add(dic_row)
        }
        print(arrResult)
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(DBConnect())!)
            print("error finalizing prepared statement: \(errmsg)")
            CompletionHandler(false, errmsg, arrResult)
        } else {
            CompletionHandler(true, "Select query run successfully", arrResult)
        }
        statement = nil
    }
    
    // MARK:  - Delete a data on table
    func DeleteSingleRow(Tblname: String, Columname: String , Value : String , CompletionHandler: (_ Status : Bool , _ MSG : String) -> ()) -> Void {
        var statement: OpaquePointer?
        let Del_Query = "Delete from \(Tblname) where \(Columname) = '\(Value)'"
        print(Del_Query)
        if sqlite3_prepare_v2(DBConnect(), Del_Query, -1, &statement, nil) != SQLITE_OK {
            let errorMSg = "Delete Query Error \(String(cString: sqlite3_errmsg(DBConnect())))"
            print(errorMSg)
            CompletionHandler(false,errorMSg)
        }
        
        if sqlite3_step(statement) != SQLITE_OK {
            let errorMSg = "Delete Query Error \(String(cString: sqlite3_errmsg(DBConnect())))"
            print(errorMSg)
            CompletionHandler(false,errorMSg)
        }else{
            CompletionHandler(true,"Delted row successfully")
        }
    }
    
}
