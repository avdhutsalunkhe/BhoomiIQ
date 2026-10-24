from fastapi import APIRouter
from typing import List
from app.models.schemas import AgronomicGuide, FactoryScheme, FactoryFacility

router = APIRouter(prefix="/learn", tags=["Farm Academy, Schemes & Facilities"])

GUIDES_DB: List[AgronomicGuide] = [
    AgronomicGuide(
        id="g-1",
        stage="After harvest",
        stage_mr="कापणीनंतर",
        title="Trash Management & Mulching",
        title_mr="पाचट व्यवस्थापन आणि नियोजन",
        summary="Manage sugarcane trash by shredding or mulching across alternate furrows. Apply decomposing fungus to accelerate nutrient recycling.",
        summary_mr="ऊस पाचट जाळण्याऐवजी पाचट कुट्टी मशीनद्वारे सरीमध्ये दाबून ठेवावे. पाचट कुजवणारे जिवाणू वापरावेत.",
        category="Harvest",
        dosages=[
            "Decomposing Culture: 2 kg per acre with 80 kg Single Super Phosphate",
            "Urea: 25 kg per acre to balance C:N ratio"
        ],
        safety_notes="Never burn trash in field; burning destroys beneficial microbes and volatilizes organic carbon."
    ),
    AgronomicGuide(
        id="g-2",
        stage="General guidance",
        stage_mr="सर्वसाधारण मार्गदर्शन",
        title="Co 86032 Variety Characteristics",
        title_mr="को. ८६०३२ वाण संपूर्ण माहिती",
        summary="Co 86032 (Nira) is an early-mid maturity miracle cane known for high sugar recovery and excellent ratoonability across Southern Maharashtra.",
        summary_mr="को. ८६०३२ हा वाण उच्च साखर उतारा, दुष्काळ प्रतिकारक्षमता आणि उत्तम खोडवा क्षमतेसाठी अत्यंत प्रसिद्ध आहे.",
        category="Seed",
        dosages=[
            "Adsali Season: Maturity 15-18 months",
            "Suru / Pre-seasonal: Maturity 12-14 months"
        ]
    ),
    AgronomicGuide(
        id="g-3",
        stage="Before planting",
        stage_mr="लागवडीपूर्वी",
        title="Soil & Water Quality Diagnostic",
        title_mr="माती व पाणी परीक्षण",
        summary="Collect composite soil samples from 0-30 cm depth. Test electrical conductivity (EC), pH, and organic carbon before cane seed selection.",
        summary_mr="लागवडीपूर्वी मातीचे नमुने घेऊन खत मात्रांचे नियोजन करा. जमिनीतील सेंद्रिय कर्ब व क्षारता तपासा.",
        category="Soil"
    ),
    AgronomicGuide(
        id="g-4",
        stage="2 days after planting",
        stage_mr="लागवडीनंतर २ दिवस",
        title="Seed Treatment Protocol",
        title_mr="बेणे प्रक्रिया पद्धत",
        summary="Dip cane setts for 10-15 minutes in fungicide solution before planting to prevent Pineapple Disease and Smut.",
        summary_mr="ऊस बेणे १०-१५ मिनिटे बुरशीनाशक द्रावणात बुडवून लागवड करावी जेणेकरून काणी व कुजव्या रोगाचा प्रादुर्भाव टळतो.",
        category="Seed",
        dosages=[
            "Carbendazim (Bavistin): 3 g (or 3 ml) per litre of clean water",
            "Chlorpyrifos: 2 ml per litre if termite infestation is historically present"
        ],
        safety_notes="Wear rubber gloves and protective goggles while handling treated setts."
    ),
    AgronomicGuide(
        id="g-5",
        stage="General guidance",
        stage_mr="सर्वसाधारण मार्गदर्शन",
        title="Phule 265 Variety Characteristics",
        title_mr="फुले २६५ वाण माहिती",
        summary="Phule 265 is a high-yielding, thick cane variety well-adapted to saline soils and heavy soils with exceptional tonnage potential.",
        summary_mr="क्षारपड व भारी जमिनीतही भरघोस उत्पादन देणारा जाड कांड्यांचा वाण.",
        category="Seed"
    ),
    AgronomicGuide(
        id="g-6",
        stage="10 days after harvest",
        stage_mr="तोडणीनंतर १० दिवस",
        title="Trash Mulching & Super Phosphate",
        title_mr="पाचट आच्छादन व सुपर फॉस्फेट",
        summary="Broadcast single super phosphate (SSP) over shredded trash to provide phosphorus for tillering and microbial digestion.",
        summary_mr="पाचटावर २ पोती सिंगल सुपर फॉस्फेट आणि १ पोते युरिया समप्रमाणात टाकावे.",
        category="Nutrition",
        dosages=["Single Super Phosphate: 2 bags (100 kg) per acre", "Urea: 1 bag (45 kg) per acre"]
    )
]

# Deduplicated Schemes
SCHEMES_DB: List[FactoryScheme] = [
    FactoryScheme(
        id="scheme-drip",
        title="Factory Drip Irrigation Incentive Scheme",
        title_mr="ठिबक सिंचन कारखाना अनुदान योजना",
        benefit="10% Factory Subsidy over Government Subsidy + ₹5,000 per acre bonus",
        benefit_mr="शासकीय अनुदानाव्यतिरिक्त १०% कारखाना अनुदान + ₹५,००० प्रति एकर",
        eligibility="Registered sugarcane farmer members of Rajarambapu Patil SSK with active field registration.",
        eligibility_mr="कारखान्याचे नोंदणीकृत शेतकरी सभासद, ज्यांची ऊस नोंद सक्रिय आहे.",
        contact_name="Agriculture Extension Wing",
        contact_phone="+91 2342 220455"
    ),
    FactoryScheme(
        id="scheme-drainage",
        title="Rajaram Bapu Subsurface Drainage Scheme",
        title_mr="राजारामबापू भूगर्भीय निचरा प्रणाली योजना",
        benefit="Subsurface corrugated perforated pipe drainage with interest-free factory credit loan of ₹4,000/acre",
        benefit_mr="क्षारपड व पाणथळ जमिनीसाठी बिनव्याजी ₹४,००० प्रति एकर कर्ज व तांत्रिक मार्गदर्शन",
        eligibility="Farmer members whose fields suffer from salinity, high water table, or waterlogging.",
        eligibility_mr="पाणथळ किंवा क्षारयुक्त जमीन असलेले सभासद शेतकरी.",
        contact_name="Land Development Cell",
        contact_phone="+91 2342 220459"
    ),
    FactoryScheme(
        id="scheme-compost",
        title="Factory Press Mud & Enriched Bio-compost",
        title_mr="कारखाना मळी व समृद्ध कंपोस्ट खत योजना",
        benefit="Subsidized factory press mud delivered directly to field at ₹450 per tonne",
        benefit_mr="सेंद्रिय कर्ब वाढीसाठी नाममात्र दरात थेट शेतावर मळी कंपोस्ट खत पोहोच",
        eligibility="All registered farmers preparing land for adsali or suru cane planting.",
        eligibility_mr="नवीन लागवड करणारे सर्व ऊस उत्पादक शेतकरी.",
        contact_name="By-Products Division",
        contact_phone="+91 2342 220462"
    )
]

# Deduplicated Facilities
FACILITIES_DB: List[FactoryFacility] = [
    FactoryFacility(
        id="fac-drone-camera",
        title="Multispectral Drone Imagery Survey",
        title_mr="मल्टीस्पेक्ट्रल ड्रोन कॅमेरा सर्वेक्षण",
        department="Agriculture Department",
        department_mr="कृषी विभाग",
        description="Ultra-high 5cm resolution 5-band multispectral survey generating calibrated NDVI, NDRE, and canopy height maps for micro-zoning sub-acre plots.",
        description_mr="अत्याधुनिक ५-बँड ड्रोनद्वारे शेताचे सूक्ष्म सर्वेक्षण. NDVI व पानांमधील अन्नद्रव्य कमतरतेचे अचूक विश्लेषण.",
        lead_time="Survey completed within 48 hours of booking",
        contact_phone="+91 98224 56789"
    ),
    FactoryFacility(
        id="fac-soil-lab",
        title="Central Soil & Water Testing Laboratory",
        title_mr="मध्यवर्ती माती व पाणी परीक्षण केंद्र",
        department="Factory Headquarters, Rajaramnagar",
        department_mr="कारखाना मुख्यालय, राजारामनगर",
        description="ISO-calibrated wet-chemistry testing of N, P, K, pH, Electrical Conductivity (EC), Organic Carbon, Zinc, and Iron with digitized fertilizer recommendations.",
        description_mr="एनपीके, सामू (pH), क्षारता, सेंद्रिय कर्ब व सूक्ष्म अन्नद्रव्यांची अचूक प्रयोगशाळा चाचणी व खत मात्रा कार्ड.",
        lead_time="Digital report delivered to BhoomiIQ app within 4 days",
        contact_phone="+91 2342 220470"
    ),
    FactoryFacility(
        id="fac-drone-spray",
        title="Precision Drone Spraying Fleet",
        title_mr="ड्रोन फवारणी सेवा केंद्र",
        department="Cane Protection Division",
        department_mr="ऊस संरक्षण विभाग",
        description="Fleet of 10L/16L agricultural drones for uniform micronutrient, bio-stimulant, or approved fungicide spraying across tall mature sugarcane canopies without trampling.",
        description_mr="मोठ्या वाढलेल्या उसातही पिकाचे नुकसान न होता समान व जलद सूक्ष्म अन्नद्रव्य किंवा औषध फवारणी (२०२१ पासून कार्यरत).",
        lead_time="Slot confirmed within 24 hours",
        contact_phone="+91 98224 56790"
    )
]


@router.get("/guides", response_model=List[AgronomicGuide])
async def list_guides():
    return GUIDES_DB


@router.get("/schemes", response_model=List[FactoryScheme])
async def list_schemes():
    return SCHEMES_DB


@router.get("/facilities", response_model=List[FactoryFacility])
async def list_facilities():
    return FACILITIES_DB
