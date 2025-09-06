import Foundation

enum DTAPicklists {
    static let assessmentStartEndSpotOptions = [
        "Start (fill out all fields)",
        "End (see start for rest of this info.)",
        "Spot 1",
        "Spot 2",
        "Spot 3",
        "Spot 4",
        "Spot 5"
    ]
    
    static let saoOverviewOptions = ["Yes", "No"]
    
    static let saoBriefedToCrewOptions = ["Yes", "No - do not select this (communicate)"]
    
    static let primaryHazardsPresentOptions = [
        "Location or lean",
        "Deterioration of limbs, stem or roots",
        "Overhead hazards",
        "Physical Damage"
    ]
    
    static let activityOptions = [
        "Bucking/slashing", "Burn Off", "Fire Camp/Command Post", "Hand guard",
        "Heavy Eq./Heli staging, marshalling areas", "Heavy equipment use",
        "Heavy Vehicles - Trail/overgrown road", "Hose Trail (black)", "Hose trail (green)",
        "Light vehicle parking", "Line locating", "Maintained Resource Rd. Heavy Vehicles",
        "Med/heavy heli - rotor wash exposure", "Light/inter heli - rotor wash exposure",
        "Mop Up", "Manned pumpsite", "Patrol", "Road/trail travel - light vehicles (black)",
        "Road/trail travel - light vehicles (green)", "Tree falling (not DTF)",
        "Unmanned pumpsite (black)", "Unmanned pump site (green)"
    ]

    static let levelOfDisturbanceOptions = ["0-VLR", "1-Low", "2-Medium", "3-High"]
    
    static let lodLowHazardsOptions = [
        "Not Applicable",
        ">50% cross section damage/decay",
        "Greatly >50% lateral root damage/decay",
        "Insecurely lodged/hung up",
        "Recent lean AND Root decay (>50%)",
        "Spongy snags (heart rot conks)"
    ]
    
    static let lodMediumFirLarchPineSpruceOptions = [
        "Not Applicable", "Split Trunk", "Roots Inspection", "Butt and Stem Cankers",
        "Dead Limbs", "Stem Damage", "Fungal Fruiting Bodies", "Witches’ Broom",
        "Hazardous Top", "Tree lean (4-8 trees) >10% + root probs",
        "Tree Lean (Class 1-3) >15%+root probs", "Thick Sloughing Bark",
        "Multiple trees, multiple defects"
    ]
    
    static let lodMediumRedYellowCedarOptions = [
        "Not Applicable", "Dead Limbs", "Hazardous Top", "Multiple trees, Multiple Defects",
        "Root Inspection", "Sapwood Slabs", "Split Trunk", "Stem damage",
        "Tree Lean (class 1-3)", "Tree Lean (Class 4-8)"
    ]
    
    static let fuelTypeOptions = [
        "C1 spruce lichen woodland", "C2 boreal spruce", "C3 mature jack/lodgepole pine",
        "C4 immature jack/lodgepole pine", "C5 red and white pine", "C6 conifer plantation",
        "C7 ponderosa pine - Doulas Fir", "D1 leafless aspen", "M1 boreal mixed wood leafless",
        "M2 boreal mixed wood green", "M3 dead balsam fir mixed wood leafless",
        "M4 dead balsam fir mixed wood green", "O1a matted grass", "O1b standing grass",
        "S1 jack or lodgepole pine slash", "S2 white spruce/balsam slash",
        "S3 - coastal cedar/hemlock/douglas fir slash"
    ]
    
    static let dtaMarkingProtocolFollowedOptions = ["Yes", "No (explain in Comments)"]
    static let noWorkZonesOptions = ["Yes", "No (Do not click this - brief them)", "None marked"]
    static let assessedMin1_5TreeLengthsOptions = ["Yes", "No (Explain in Comments)"]
    static let assessDistanceFromWorkAreaOptions = ["1.5 TL or Strike Dist. (slope adjusted)", "2 Tree Lengths (Slope adjusted)"]
    static let areaBetweenPointsSafeForWorkOptions = ["Yes", "No (explain in comments)"]
    static let reassessmentNeededOptions = ["", "Everyday", "Every 3 days", "Not required"]
}
