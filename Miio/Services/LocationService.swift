//
//  LocationService.swift
//  Miio
//
//  Created by Miqueias Saldanha on 04/12/25.
//

import Foundation
import CoreLocation
import Combine

/// Serviço responsável por gerenciar localização e geocodificação
class LocationService: NSObject {
    private let locationManager = CLLocationManager()
    private var locationCompletion: ((CLLocation?) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Solicita a localização atual do dispositivo
    /// - Parameter completion: Callback com a localização ou nil
    func requestCurrentLocation(completion: @escaping (CLLocation?) -> Void) {
        self.locationCompletion = completion
        
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            completion(nil)
            locationCompletion = nil
        @unknown default:
            completion(nil)
            locationCompletion = nil
        }
    }
    
    /// Busca localizações baseado em uma string de endereço
    /// - Parameters:
    ///   - query: Texto de busca
    ///   - completion: Callback com array de localizações encontradas (chamado no MainActor)
    func searchLocations(query: String, completion: @escaping @MainActor ([Location]) -> Void) {
        guard !query.isEmpty, query.count > 2 else {
            Task { @MainActor in
                completion([])
            }
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(query) { placemarks, error in
            Task { @MainActor in
                if let error = error {
                    // Erro na busca de localização é tratado silenciosamente
                    completion([])
                    return
                }
                
                guard let placemarks = placemarks else {
                    completion([])
                    return
                }
                
                let locations = placemarks.prefix(5).compactMap { placemark -> Location? in
                    guard let coordinate = placemark.location?.coordinate else { return nil }
                    
                    let name = placemark.name ?? placemark.locality ?? "Localização"
                    let address = [
                        placemark.thoroughfare,
                        placemark.subThoroughfare,
                        placemark.locality,
                        placemark.administrativeArea,
                        placemark.country
                    ]
                        .compactMap { $0 }
                        .joined(separator: ", ")
                    
                    return Location(
                        coordinate: coordinate,
                        name: name,
                        address: address.isEmpty ? nil : address
                    )
                }
                
                completion(locations)
            }
        }
    }
    
    /// Faz geocodificação reversa de uma localização
    /// - Parameters:
    ///   - location: Localização para geocodificar
    ///   - completion: Callback com a localização formatada (chamado no MainActor)
    func reverseGeocodeLocation(_ location: CLLocation, completion: @escaping @MainActor (Location?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            Task { @MainActor in
                if let error = error {
                    // Erro na geocodificação reversa é tratado silenciosamente
                    completion(nil)
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    completion(Location(
                        coordinate: location.coordinate,
                        name: "Localização atual",
                        address: nil
                    ))
                    return
                }
                
                let name = placemark.name ?? placemark.locality ?? "Localização atual"
                let address = [
                    placemark.thoroughfare,
                    placemark.subThoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                
                completion(Location(
                    coordinate: location.coordinate,
                    name: name,
                    address: address.isEmpty ? nil : address
                ))
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationCompletion?(nil)
            locationCompletion = nil
            return
        }
        locationCompletion?(location)
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Erro ao obter localização é tratado silenciosamente
        locationCompletion?(nil)
        locationCompletion = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if locationCompletion != nil {
                manager.requestLocation()
            }
        case .denied, .restricted:
            locationCompletion?(nil)
            locationCompletion = nil
        case .notDetermined:
            break
        @unknown default:
            locationCompletion?(nil)
            locationCompletion = nil
        }
    }
}

