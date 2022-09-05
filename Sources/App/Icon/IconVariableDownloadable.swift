

protocol IconVariableDownloadable: GenericVariableMixing {
    var skipHour0: Bool { get }
    var isAveragedOverForecastTime: Bool { get }
    var isAccumulatedSinceModelStart: Bool { get }
    var multiplyAdd: (multiply: Float, add: Float)? { get }
    var interpolationType: InterpolationType { get }
    func getVarAndLevel(domain: IconDomains) -> (variable: String, cat: String, level: Int?)
}

extension IconSurfaceVariable: IconVariableDownloadable {
    /// Vmax and precip always are empty in the first hour. Weather codes differ a lot in hour 0.
    var skipHour0: Bool {
        switch self {
        case .precipitation: return true
        case .windgusts_10m: return true
        case .sensible_heatflux: return true
        case .latent_heatflux: return true
        case .direct_radiation: return true
        case .diffuse_radiation: return true
        case .weathercode: return true
        default: return false
        }
    }
    
    var isAveragedOverForecastTime: Bool {
        switch self {
        case .diffuse_radiation: return true
        case .direct_radiation: return true
        case .sensible_heatflux: return true
        case .latent_heatflux: return true
        default: return false
        }
    }
    
    var interpolationType: InterpolationType {
        switch self {
        case .temperature_2m: return .hermite(bounds: nil)
        case .cloudcover: return .linear
        case .cloudcover_low: return .linear
        case .cloudcover_mid: return .linear
        case .cloudcover_high: return .linear
        case .relativehumidity_2m: return .hermite(bounds: 0...100)
        case .precipitation: return .linear
        case .weathercode: return .nearest
        case .v_10m: return .hermite(bounds: nil)
        case .u_10m: return .hermite(bounds: nil)
        case .snow_depth: return .linear
        case .sensible_heatflux: return .hermite_backwards_averaged(bounds: nil)
        case .latent_heatflux: return .hermite_backwards_averaged(bounds: nil)
        case .windgusts_10m: return .linear
        case .freezinglevel_height: return .hermite(bounds: nil)
        case .dewpoint_2m: return .hermite(bounds: nil)
        case .diffuse_radiation: return .solar_backwards_averaged
        case .direct_radiation: return .solar_backwards_averaged
        case .soil_temperature_0cm: return .hermite(bounds: nil)
        case .soil_temperature_6cm: return .hermite(bounds: nil)
        case .soil_temperature_18cm: return .hermite(bounds: nil)
        case .soil_temperature_54cm: return .hermite(bounds: nil)
        case .soil_moisture_0_1cm: return .hermite(bounds: nil)
        case .soil_moisture_1_3cm: return .hermite(bounds: nil)
        case .soil_moisture_3_9cm: return .hermite(bounds: nil)
        case .soil_moisture_9_27cm: return .hermite(bounds: nil)
        case .soil_moisture_27_81cm: return .hermite(bounds: nil)
        case .v_80m: return .hermite(bounds: nil)
        case .u_80m: return .hermite(bounds: nil)
        case .v_120m: return .hermite(bounds: nil)
        case .u_120m: return .hermite(bounds: nil)
        case .v_180m: return .hermite(bounds: nil)
        case .snowfall_convective_water_equivalent: return .linear
        case .snowfall_water_equivalent: return .linear
        case .u_180m: return .hermite(bounds: nil)
        case .showers: return .linear
        case .pressure_msl: return .hermite(bounds: nil)
        case .rain: return .linear
        }
    }
    
    var isAccumulatedSinceModelStart: Bool {
        switch self {
        case .snowfall_water_equivalent: fallthrough
        case .snowfall_convective_water_equivalent: fallthrough
        case .precipitation: fallthrough
        case .showers: fallthrough
        case .rain: return true
        default: return false
        }
    }
    
    func getVarAndLevel(domain: IconDomains) -> (variable: String, cat: String, level: Int?) {
        switch self {
        case .soil_temperature_0cm: return ("t_so", "soil-level", 0)
        case .soil_temperature_6cm: return ("t_so", "soil-level", 6)
        case .soil_temperature_18cm: return ("t_so", "soil-level", 18)
        case .soil_temperature_54cm: return ("t_so", "soil-level", 54)
        case .soil_moisture_0_1cm: return ("w_so", "soil-level", 0)
        case .soil_moisture_1_3cm: return ("w_so", "soil-level", 1)
        case .soil_moisture_3_9cm: return ("w_so", "soil-level", 3)
        case .soil_moisture_9_27cm: return ("w_so", "soil-level", 9)
        case .soil_moisture_27_81cm: return ("w_so", "soil-level", 27)
        case .u_80m: return ("u", "model-level", domain.numberOfModelFullLevels-2)
        case .v_80m: return ("v", "model-level", domain.numberOfModelFullLevels-2)
        case .u_120m: return ("u", "model-level", domain.numberOfModelFullLevels-3)
        case .v_120m: return ("v", "model-level", domain.numberOfModelFullLevels-3)
        case .u_180m: return ("u", "model-level", domain.numberOfModelFullLevels-4)
        case .v_180m: return ("v", "model-level", domain.numberOfModelFullLevels-4)
        default: return (omFileName, "single-level", nil)
        }
    }
    
    var multiplyAdd: (multiply: Float, add: Float)? {
        switch self {
        case .temperature_2m: fallthrough
        case .dewpoint_2m: fallthrough
        case .soil_temperature_0cm: fallthrough
        case .soil_temperature_6cm: fallthrough
        case .soil_temperature_18cm: fallthrough
        case .soil_temperature_54cm:
            return (1, -273.15) // Temperature is stored in kelvin. Convert to celsius
        case .pressure_msl:
            return (1/100, 0) // convert to hPa
        case .soil_moisture_0_1cm:
            return (0.001 / 0.01, 0) // 1cm depth
        case .soil_moisture_1_3cm:
            return (0.001 / 0.02, 0) // 2cm depth
        case .soil_moisture_3_9cm:
            return (0.001 / 0.06, 0) // 6cm depth
        case .soil_moisture_9_27cm:
            return (0.001 / 0.18, 0) // 18cm depth
        case .soil_moisture_27_81cm:
            return (0.001 / 0.54, 0) // 54cm depth
        default:
            return nil
        }
    }
}

extension IconPressureVariable: IconVariableDownloadable {
    var interpolationType: InterpolationType {
        switch variable {
        case .relativehumidity: return .hermite(bounds: 0...100)
        default: return .hermite(bounds: nil)
        }
    }
    
    var isAveragedOverForecastTime: Bool {
        return false
    }
    
    var isAccumulatedSinceModelStart: Bool {
        return false
    }
    
    var skipHour0: Bool {
        return false
    }
    
    var multiplyAdd: (multiply: Float, add: Float)? {
        switch variable {
        case .temperature:
            return (1, -273.15)
        default:
            return nil
        }
    }
    
    func getVarAndLevel(domain: IconDomains) -> (variable: String, cat: String, level: Int?) {
        switch variable {
        case .temperature:
        return ("t", "pressure-level", level)
        case .wind_u_component:
            return ("u", "pressure-level", level)
        case .wind_v_component:
            return ("v", "pressure-level", level)
        case .geopotential_height:
            return ("fi", "pressure-level", level)
        case .relativehumidity:
            return ("relhum", "pressure-level", level)
        }
    }
}
