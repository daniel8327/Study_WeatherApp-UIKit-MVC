//
//  CoreDataHelper.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/05/03.
//

import CoreData
import Foundation

class CoreDataHelper {
    
    /// CoreData Fetch
    /// - Returns: [Location]
    class func fetch() -> [NSManagedObject] {
        let context = _AD.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CD_Location")
        
        do {
            // 정렬 속성
            let sortCurrentArea = NSSortDescriptor(key: "currentArea", ascending: false)
            let sortRegDate = NSSortDescriptor(key: "regdate", ascending: true)
            
            fetchRequest.sortDescriptors = [sortCurrentArea, sortRegDate]
            
            let result = try context.fetch(fetchRequest)
            
            print("fetched result: \(result)")
            
            return result
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
    
    class func fetchByCurrent() -> NSManagedObject? {
        
        let context = _AD.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CD_Location")
        
        fetchRequest.predicate = NSPredicate(format: "currentArea == %i", 1)
        
        print("fetchRequest.predicate: \(fetchRequest.predicate!)")
        
        //let currentArea = try? context.fetch(fetchRequest)
        //print("currentArea: \(currentArea)")
        //print("currentArea.first: \(currentArea?.first)")
        
        return try? context.fetch(fetchRequest).first ?? nil
    }
    
    class func fetchByKey(code: String) -> NSManagedObject? {
        
        let context = _AD.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CD_Location")
        
        fetchRequest.predicate = NSPredicate(format: "code == %@", code)
        
        return try? context.fetch(fetchRequest).first ?? nil
    }
    
    
    @available(*, deprecated)
    @discardableResult
    func edit(object: NSManagedObject, location: LocationVO) -> Bool {
        
        let context = _AD.persistentContainer.viewContext
        
        print("111: de222저장: \(location.city) \(location.currentArea)")
        
        object.setValue(location.city, forKey: "city")
        object.setValue(location.code, forKey: "code")
        object.setValue(location.recent_temp, forKey: "recent_temp")
        object.setValue(location.currentArea, forKey: "currentArea")
        object.setValue(location.latitude, forKey: "latitude")
        object.setValue(location.longitude, forKey: "longitude")
        object.setValue(location.timezone, forKey: "timezone")
        
        object.setValue(Date(), forKey: "regdate")
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    @available(*, deprecated)
    @discardableResult
    func save(location: LocationVO) -> Bool {
                
        let context = _AD.persistentContainer.viewContext
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "CD_Location", into: context)
        
        object.setValue(location.currentArea, forKey: "currentArea")
        object.setValue(location.city, forKey: "city")
        object.setValue(location.code, forKey: "code")
        object.setValue(location.longitude, forKey: "longitude")
        object.setValue(location.latitude, forKey: "latitude")
        object.setValue(location.recent_temp, forKey: "recent_temp")
        object.setValue(Date(), forKey: "regdate")
        object.setValue(location.timezone, forKey: "timezone")
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    
    /// Insert or Update
    /// - Parameters:
    ///   - object: NSManagedObject?
    ///   - location: LocationVO
    /// - Returns: Bool
    @discardableResult
    class func save(object: NSManagedObject?, location: LocationVO) -> Bool {
                
        let context = _AD.persistentContainer.viewContext
        
        var obj: NSManagedObject!
        
        if nil != object {
            obj = object
        } else {
            obj = NSEntityDescription.insertNewObject(forEntityName: "CD_Location", into: context)
        }
        
        print("111: 저장: \(location.city) \(location.currentArea)")
        obj.setValue(location.currentArea, forKey: "currentArea")
        obj.setValue(location.city, forKey: "city")
        obj.setValue(location.code, forKey: "code")
        obj.setValue(location.longitude, forKey: "longitude")
        obj.setValue(location.latitude, forKey: "latitude")
        obj.setValue(location.recent_temp, forKey: "recent_temp")
        obj.setValue(Date(), forKey: "regdate")
        obj.setValue(location.timezone, forKey: "timezone")
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    @discardableResult
    class func editByCode(cityCode: String, temperature: Int?) -> Bool {
        
        print("cityCode: \(cityCode)")
        
        let context = _AD.persistentContainer.viewContext
        
        if let object = fetchByKey(code: cityCode) {
            
            if let temperature = temperature {
                object.setValue(temperature, forKey: "recent_temp")
            }
            
            object.setValue(Date(), forKey: "regdate")
            
            do {
                try context.save()
                return true
            } catch {
                context.rollback()
                return false
            }
        }
        
        return false
    }
    
    @discardableResult
    class func delete(object: NSManagedObject) -> Bool {
        
        let context = _AD.persistentContainer.viewContext
        
        context.delete(object)
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    class func deleteByCode(code: String) -> Bool {
    
        if let result = fetchByKey(code: code) {
            return delete(object: result)
        } else {
            return false
        }
    }
}
