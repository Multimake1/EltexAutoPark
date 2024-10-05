//
//  ViewController.swift
//  EltexAutoPark
//
//  Created by Арсений on 03.10.2024.
//

import UIKit

struct Cargo {
    var description: String
    var weight: Int
    var type: CargoType
    init?(description: String, weight: Int, type: CargoType) {
        if weight >= 0 {
            self.description = description
            self.weight = weight
            self.type = type
        }
        else {
            return nil
        }
    }
}


enum CargoType: Equatable {
    case fragile(Int) //максимальная скорость транспорта для хрупкого груза
    case perishable(Int) //оптимальная температура скоропортящегося груза
    case bulk(String) //памятка поведения с рассыпчатым грузом
    static func == (lhs: CargoType, rhs: CargoType) -> Bool {
        switch (lhs, rhs) {
        case (.fragile, .fragile): return true
        case (.perishable, .perishable): return true
        case (.bulk, .bulk): return true
        default: return false
        }
    }
}

class Vehicle {
    var make: String
    var model: String
    var year: Int
    var capacity: Int
    var fuelTank: Int
    var fuelConsumption: Int
    var types: [CargoType]?
    var currentLoad: Int?
    init(make: String, model: String, year: Int, capacity: Int, fuelTank: Int, fuelConsumption: Int, types: [CargoType]?, currentLoad: Int? = nil) {
        self.make = make
        self.model = model
        self.year = year
        self.capacity = capacity
        self.fuelTank = fuelTank //Объем топливного бака в литрах
        self.fuelConsumption = fuelConsumption //Расход в литрах на 100 км
        self.types = (types ?? [.bulk("asas"), .fragile(20), .perishable(120)])
        self.currentLoad = currentLoad
    }
    func loadCargo(cargo: Cargo) {
        if cargo.weight <= capacity && currentLoad == nil
        {
            if types?.contains(where: {$0 == cargo.type}) == true {
                currentLoad = (currentLoad ?? 0) + cargo.weight
            }
            else {
                print("Тип груза не соответствует перевозимому")
            }
        }
        else {
            print("Ошибка! Текущая грузоподьемность не позволяет загрузить новый груз, либо груз уже загружен")
        }
    }
    func loadCargoCheck(cargo: Cargo) -> Bool { // Возвращаемое значение добавлено для выполнения части 2, чтобы проверить что мы можем загрузить груз не повышая при этом грузоподьемость
        if cargo.weight <= capacity && currentLoad == nil
        {
            if types?.contains(where: {$0 == cargo.type}) == true {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
    func unloadCargo(){
        currentLoad = nil
    }
}

class Truck: Vehicle {
    var trailerAttached: Bool
    var trailerCapacity: Int?
    var trailerTypes: [CargoType]?
    init(make: String, model: String, year: Int, capacity: Int, fuelTank: Int, fuelConsumption: Int, types: [CargoType]?, currentLoad: Int? = nil, trailerAttached: Bool, trailerCapacity: Int?, trailerTypes: [CargoType]?) {
        self.trailerAttached = trailerAttached
        self.trailerCapacity = trailerCapacity
        self.trailerTypes = (trailerTypes ?? [.bulk("asas"), .fragile(20), .perishable(120)])
        super.init(make: make, model: model, year: year, capacity: capacity, fuelTank: fuelTank, fuelConsumption: fuelConsumption, types: (types ?? [.bulk("asas"), .fragile(20), .perishable(120)]), currentLoad: currentLoad)
    }
    
    var getTrailerCapacity: Int {
        get {
            return (trailerCapacity ?? 0)
        }
    }
    
    
    override func loadCargo(cargo: Cargo) {
        if types?.contains(where: {$0 == cargo.type}) == true {
            if cargo.weight <= capacity && currentLoad == nil {
                currentLoad = (currentLoad ?? 0) + cargo.weight
            }
            else if trailerAttached == true && trailerTypes?.contains(where: {$0 == cargo.type}) == true {
                if cargo.weight <= trailerCapacity! + capacity && currentLoad == nil {
                    currentLoad = (currentLoad ?? 0) + cargo.weight
                }
                else {
                    print("Ошибка! Груз не поместился в грузовик и прицеп")
                }
            }
            else {
                print("Ошибка! Груз не поместился в грузовик и не подошел по типу в прицеп")
            }
        }
        else if trailerAttached == true && trailerTypes?.contains(where: {$0 == cargo.type}) == true {
            if cargo.weight <= trailerCapacity! && currentLoad == nil {
                currentLoad = (currentLoad ?? 0) + cargo.weight
                print("Груз загрузили только в прицеп")
            }
            else {
                print("Груз не поместился в прицеп")
            }
        }
        else {
            print("Груз не подошел по типу ни в грузовик, ни в прицеп")
        }
    }
    
    override func loadCargoCheck(cargo: Cargo) -> Bool { // Возвращаемое значение добавлено для выполнения части 2, чтобы проверить что мы можем загрузить груз
        if types?.contains(where: {$0 == cargo.type}) == true {
            if cargo.weight <= capacity && currentLoad == nil {
                return true
            }
            else if trailerAttached == true && trailerTypes?.contains(where: {$0 == cargo.type}) == true {
                if cargo.weight <= trailerCapacity! + capacity && currentLoad == nil {
                    return true
                }
                else {
                    return false
                }
            }
            else {
                return false
            }
        }
        else if trailerAttached == true && trailerTypes?.contains(where: {$0 == cargo.type}) == true {
            if cargo.weight <= trailerCapacity! && currentLoad == nil {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
}

class Fleet {
    var vehicles = [Vehicle]()
    func addVehicle(vehicle : Vehicle) {
        vehicles.append(vehicle)
    }
    
    func totalCapacity() -> Int {
        var totalCapacity: Int = 0
        for vehicle in vehicles {
            totalCapacity += vehicle.capacity
        }
        return totalCapacity
    }
    
    func totalCurrentLoad() -> Int {
        var totalCurrentLoad: Int = 0
        for vehicle in vehicles {
            totalCurrentLoad = totalCurrentLoad + (vehicle.currentLoad ?? 0)
        }
        return totalCurrentLoad
    }
    
    func canGo(cargo: [Cargo], path: Int) -> String {
        for vehicle in vehicles { // опустошаем машины если там были какие либо загрузки и вдальнейшем проверять что машина загружена именно нашим грузом из массива
            vehicle.unloadCargo()
        }
        for cargo in cargo {
            var cargoLoaded: Bool = false
            for vehicle in vehicles {
                if vehicle.loadCargoCheck(cargo: cargo) == true && ((vehicle.fuelTank * 100 / vehicle.fuelConsumption) / 2) >= path {
                    vehicle.loadCargo(cargo: cargo) // загружаем груз и помечаем что в эту машину больше грузить нельзя
                    cargoLoaded = true
                    break
                }
            }
            if cargoLoaded == false {
                return ("Подходящая машина для груза " + String(cargo.description) + " не найдена")
            }
        }
        return "Все грузы успешно загружены и могут быть отправлены на указанное расстояние"
    }
}
    
func info(fleet: Fleet) {
    for vehicle in fleet.vehicles {
        print("В автопарке есть машина: " + String(vehicle.make) + " " + String(vehicle.model) + " " + String(vehicle.year) + " года, грузоподъемностью - " + String(vehicle.capacity) + " , объемом топливного бака " + String(vehicle.fuelTank) + " л и расходом бензина " + String(vehicle.fuelConsumption) + " л на 100 км")
    }
    print("Общая вместимость автопарка " + String(fleet.totalCapacity()))
    print("Обшая загруженность автопарка " + String(fleet.totalCurrentLoad()))
}
    
class ViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        var fleet: Fleet = Fleet()
        var car1: Vehicle = Vehicle(make: "BMW", model: "X3", year: 2010, capacity: 2500, fuelTank: 60, fuelConsumption: 6, types: [.bulk("asda"),.fragile(120)])
        var car2: Vehicle = Vehicle(make: "MERS", model: "S-CLASS", year: 2020, capacity: 1500, fuelTank: 50, fuelConsumption: 7, types: [CargoType.perishable(10)])
        var car3: Vehicle = Vehicle(make: "AUDI", model: "QUATTRO", year: 2022, capacity: 3000, fuelTank: 54, fuelConsumption: 9, types: nil)
        var truck1: Truck = Truck(make: "TOYOTA", model: "PRIMUS", year: 2004, capacity: 7000, fuelTank: 120, fuelConsumption: 10, types: nil, trailerAttached: true, trailerCapacity: 1000, trailerTypes: nil)
        var truck2: Truck = Truck(make: "MAN", model: "H1", year: 2021, capacity: 8000, fuelTank: 140, fuelConsumption: 8, types: [.fragile(100), .bulk("asas")], trailerAttached: true, trailerCapacity: 4000, trailerTypes: [.fragile(120)])
        guard var cargo1: Cargo = Cargo(description: "песок", weight: 1500, type: .bulk("sadas")),
              var cargo2: Cargo = Cargo(description: "стекло", weight: 2500, type: .fragile(120)),
              var cargo3: Cargo = Cargo(description: "мясо", weight: 8000, type: .perishable(42)) else {return}
        fleet.addVehicle(vehicle: car1)
        fleet.addVehicle(vehicle: car2)
        fleet.addVehicle(vehicle: car3)
        fleet.addVehicle(vehicle: truck1)
        fleet.addVehicle(vehicle: truck2)
        print(fleet.canGo(cargo: [cargo3, cargo2], path: 600))
        for vehicle in fleet.vehicles {
            vehicle.unloadCargo()
        }
        fleet.vehicles[4].loadCargo(cargo: cargo2)
        fleet.vehicles[2].loadCargo(cargo: cargo1)
        fleet.vehicles[3].loadCargo(cargo: cargo3)
        info(fleet: fleet)
    }
}
    
