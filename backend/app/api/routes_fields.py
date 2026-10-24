from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
from app.models.schemas import FarmField, FieldAnalysisResponse, Coordinates
from app.services.spectral_engine import analyze_parcel_resolution, generate_field_pixel_grid
from app.services.openmeteo_service import get_weather_for_field
from app.services.copernicus_service import search_sentinel_scenes
from app.services.advisory_engine import generate_dynamic_advisory
from app.services.sugarcane_ml_engine import SugarcaneMLEngine

router = APIRouter(prefix="/fields", tags=["Fields & Parcels"])

# Repository of registered sugarcane fields
FIELDS_DATABASE: dict[str, FarmField] = {
    "plot-1": FarmField(
        id="plot-1",
        name="Karkhana Bene Mala - Plot 1",
        name_mr="कारखाना बेणे मळा - Plot 1",
        plot_number="Plot 1",
        area_acres=0.15,
        variety="Phule 265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=185,
        crop_stage="Tillering",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.067927, lng=74.274734),
        boundary_polygon=[
            (17.067526, 74.274479),
            (17.068243, 74.274786),
            (17.068264, 74.274798),
            (17.067676, 74.274872)
        ]
    ),
    "plot-2": FarmField(
        id="plot-2",
        name="Karkhana Bene Mala - Plot 2",
        name_mr="कारखाना बेणे मळा - Plot 2",
        plot_number="Plot 2",
        area_acres=0.36,
        variety="MS 10001",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=190,
        crop_stage="Ripening",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.068093, lng=74.275045),
        boundary_polygon=[
            (17.06767, 74.274899),
            (17.068504, 74.274872),
            (17.068491, 74.275176),
            (17.067708, 74.275234)
        ]
    ),
    "plot-3": FarmField(
        id="plot-3",
        name="Karkhana Bene Mala - Plot 3",
        name_mr="कारखाना बेणे मळा - Plot 3",
        plot_number="Plot 3",
        area_acres=0.3,
        variety="CoM 0265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=195,
        crop_stage="Formative",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.068107, lng=74.275327),
        boundary_polygon=[
            (17.067743, 74.275231),
            (17.068502, 74.275142),
            (17.068394, 74.275418),
            (17.067788, 74.275516)
        ]
    ),
    "plot-4": FarmField(
        id="plot-4",
        name="Karkhana Bene Mala - Plot 4",
        name_mr="कारखाना बेणे मळा - Plot 4",
        plot_number="Plot 4",
        area_acres=0.25,
        variety="Co 86032",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=200,
        crop_stage="Grand Growth",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.06816, lng=74.275772),
        boundary_polygon=[
            (17.067822, 74.275679),
            (17.068519, 74.275591),
            (17.068491, 74.275902),
            (17.067808, 74.275915)
        ]
    ),
    "plot-5": FarmField(
        id="plot-5",
        name="Karkhana Bene Mala - Plot 5",
        name_mr="कारखाना बेणे मळा - Plot 5",
        plot_number="Plot 5",
        area_acres=0.22,
        variety="Phule 265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=205,
        crop_stage="Tillering",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.068222, lng=74.276122),
        boundary_polygon=[
            (17.067928, 74.276013),
            (17.068519, 74.275915),
            (17.068508, 74.276249),
            (17.067935, 74.27631)
        ]
    ),
    "plot-6": FarmField(
        id="plot-6",
        name="Karkhana Bene Mala - Plot 6",
        name_mr="कारखाना बेणे मळा - Plot 6",
        plot_number="Plot 6",
        area_acres=0.18,
        variety="MS 10001",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=210,
        crop_stage="Ripening",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.068244, lng=74.276436),
        boundary_polygon=[
            (17.06795, 74.276384),
            (17.068526, 74.276179),
            (17.068451, 74.276586),
            (17.068051, 74.276596)
        ]
    ),
    "plot-7": FarmField(
        id="plot-7",
        name="Karkhana Bene Mala - Plot 7",
        name_mr="कारखाना बेणे मळा - Plot 7",
        plot_number="Plot 7",
        area_acres=0.14,
        variety="CoM 0265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=215,
        crop_stage="Formative",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.068344, lng=74.277214),
        boundary_polygon=[
            (17.068146, 74.277119),
            (17.068475, 74.276992),
            (17.06852, 74.277283),
            (17.068235, 74.277461)
        ]
    ),
    "plot-8": FarmField(
        id="plot-8",
        name="Karkhana Bene Mala - Plot 8",
        name_mr="कारखाना बेणे मळा - Plot 8",
        plot_number="Plot 8",
        area_acres=0.15,
        variety="Co 86032",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=220,
        crop_stage="Grand Growth",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.068424, lng=74.277528),
        boundary_polygon=[
            (17.068193, 74.277437),
            (17.068532, 74.277347),
            (17.068683, 74.277623),
            (17.068286, 74.277704)
        ]
    ),
    "plot-9": FarmField(
        id="plot-9",
        name="Karkhana Bene Mala - Plot 9",
        name_mr="कारखाना बेणे मळा - Plot 9",
        plot_number="Plot 9",
        area_acres=0.15,
        variety="Phule 265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=225,
        crop_stage="Tillering",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.068504, lng=74.27783),
        boundary_polygon=[
            (17.068245, 74.277748),
            (17.068666, 74.277684),
            (17.06875, 74.277875),
            (17.068355, 74.278014)
        ]
    ),
    "plot-10": FarmField(
        id="plot-10",
        name="Karkhana Bene Mala - Plot 10",
        name_mr="कारखाना बेणे मळा - Plot 10",
        plot_number="Plot 10",
        area_acres=0.19,
        variety="MS 10001",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=230,
        crop_stage="Ripening",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.068612, lng=74.278202),
        boundary_polygon=[
            (17.068359, 74.278043),
            (17.068792, 74.27796),
            (17.068822, 74.278316),
            (17.068476, 74.27849)
        ]
    ),
    "plot-11": FarmField(
        id="plot-11",
        name="Karkhana Bene Mala - Plot 11",
        name_mr="कारखाना बेणे मळा - Plot 11",
        plot_number="Plot 11",
        area_acres=0.28,
        variety="CoM 0265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=235,
        crop_stage="Formative",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.067966, lng=74.278372),
        boundary_polygon=[
            (17.067546, 74.278258),
            (17.068297, 74.278163),
            (17.068335, 74.278496),
            (17.067686, 74.27857)
        ]
    ),
    "plot-12": FarmField(
        id="plot-12",
        name="Karkhana Bene Mala - Plot 12",
        name_mr="कारखाना बेणे मळा - Plot 12",
        plot_number="Plot 12",
        area_acres=0.29,
        variety="Co 86032",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=240,
        crop_stage="Grand Growth",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.067861, lng=74.278073),
        boundary_polygon=[
            (17.067392, 74.278058),
            (17.068198, 74.277791),
            (17.068291, 74.278126),
            (17.067561, 74.278316)
        ]
    ),
    "plot-13": FarmField(
        id="plot-13",
        name="Karkhana Bene Mala - Plot 13",
        name_mr="कारखाना बेणे मळा - Plot 13",
        plot_number="Plot 13",
        area_acres=0.31,
        variety="Phule 265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=245,
        crop_stage="Tillering",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.067723, lng=74.277745),
        boundary_polygon=[
            (17.067202, 74.277723),
            (17.06813, 74.277453),
            (17.068204, 74.277785),
            (17.067358, 74.27802)
        ]
    ),
    "plot-14": FarmField(
        id="plot-14",
        name="Karkhana Bene Mala - Plot 14",
        name_mr="कारखाना बेणे मळा - Plot 14",
        plot_number="Plot 14",
        area_acres=0.48,
        variety="MS 10001",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=250,
        crop_stage="Ripening",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.067597, lng=74.277292),
        boundary_polygon=[
            (17.067034, 74.277216),
            (17.068038, 74.276943),
            (17.06812, 74.277375),
            (17.067195, 74.277634)
        ]
    ),
    "plot-15": FarmField(
        id="plot-15",
        name="Karkhana Bene Mala - Plot 15",
        name_mr="कारखाना बेणे मळा - Plot 15",
        plot_number="Plot 15",
        area_acres=0.57,
        variety="CoM 0265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=255,
        crop_stage="Formative",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.067438, lng=74.276667),
        boundary_polygon=[
            (17.066916, 74.276476),
            (17.067878, 74.276394),
            (17.067999, 74.276773),
            (17.06696, 74.277026)
        ]
    ),
    "plot-16": FarmField(
        id="plot-16",
        name="Karkhana Bene Mala - Plot 16",
        name_mr="कारखाना बेणे मळा - Plot 16",
        plot_number="Plot 16",
        area_acres=0.38,
        variety="Co 86032",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=260,
        crop_stage="Grand Growth",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.067315, lng=74.276252),
        boundary_polygon=[
            (17.06674, 74.276101),
            (17.067772, 74.276094),
            (17.067835, 74.276331),
            (17.066913, 74.27648)
        ]
    ),
    "plot-17": FarmField(
        id="plot-17",
        name="Karkhana Bene Mala - Plot 17",
        name_mr="कारखाना बेणे मळा - Plot 17",
        plot_number="Plot 17",
        area_acres=0.35,
        variety="Phule 265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=265,
        crop_stage="Tillering",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.067211, lng=74.275891),
        boundary_polygon=[
            (17.066652, 74.275812),
            (17.067694, 74.275691),
            (17.067737, 74.276002),
            (17.066759, 74.276059)
        ]
    ),
    "plot-18": FarmField(
        id="plot-18",
        name="Karkhana Bene Mala - Plot 18",
        name_mr="कारखाना बेणे मळा - Plot 18",
        plot_number="Plot 18",
        area_acres=0.32,
        variety="MS 10001",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=270,
        crop_stage="Ripening",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.067173, lng=74.275552),
        boundary_polygon=[
            (17.066686, 74.27541),
            (17.06762, 74.275407),
            (17.067693, 74.275622),
            (17.066695, 74.27577)
        ]
    ),
    "plot-19": FarmField(
        id="plot-19",
        name="Karkhana Bene Mala - Plot 19",
        name_mr="कारखाना बेणे मळा - Plot 19",
        plot_number="Plot 19",
        area_acres=0.38,
        variety="CoM 0265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=275,
        crop_stage="Formative",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.06709, lng=74.275164),
        boundary_polygon=[
            (17.066558, 74.275064),
            (17.067553, 74.27494),
            (17.067588, 74.27527),
            (17.06666, 74.275383)
        ]
    ),
    "plot-20": FarmField(
        id="plot-20",
        name="Karkhana Bene Mala - Plot 20",
        name_mr="कारखाना बेणे मळा - Plot 20",
        plot_number="Plot 20",
        area_acres=0.32,
        variety="Co 86032",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=280,
        crop_stage="Grand Growth",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.067017, lng=74.274796),
        boundary_polygon=[
            (17.066498, 74.274727),
            (17.067451, 74.274599),
            (17.067551, 74.274878),
            (17.066566, 74.274979)
        ]
    ),
    "plot-21": FarmField(
        id="plot-21",
        name="Karkhana Bene Mala - Plot 21",
        name_mr="कारखाना बेणे मळा - Plot 21",
        plot_number="Plot 21",
        area_acres=0.4,
        variety="Phule 265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=285,
        crop_stage="Tillering",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.066911, lng=74.27448),
        boundary_polygon=[
            (17.066317, 74.274158),
            (17.067412, 74.274518),
            (17.06744, 74.27458),
            (17.066477, 74.274663)
        ]
    ),
    "plot-22": FarmField(
        id="plot-22",
        name="Karkhana Bene Mala - Plot 22",
        name_mr="कारखाना बेणे मळा - Plot 22",
        plot_number="Plot 22",
        area_acres=0.38,
        variety="MS 10001",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=290,
        crop_stage="Ripening",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.065917, lng=74.274224),
        boundary_polygon=[
            (17.065424, 74.273952),
            (17.066163, 74.274094),
            (17.066333, 74.274459),
            (17.065749, 74.27439)
        ]
    ),
    "plot-23": FarmField(
        id="plot-23",
        name="Karkhana Bene Mala - Plot 23",
        name_mr="कारखाना बेणे मळा - Plot 23",
        plot_number="Plot 23",
        area_acres=0.37,
        variety="CoM 0265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=295,
        crop_stage="Formative",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.066123, lng=74.274769),
        boundary_polygon=[
            (17.06579, 74.274582),
            (17.06625, 74.274467),
            (17.066412, 74.274997),
            (17.06604, 74.275032)
        ]
    ),
    "plot-24": FarmField(
        id="plot-24",
        name="Karkhana Bene Mala - Plot 24",
        name_mr="कारखाना बेणे मळा - Plot 24",
        plot_number="Plot 24",
        area_acres=0.33,
        variety="Co 86032",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=300,
        crop_stage="Grand Growth",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.06586, lng=74.275216),
        boundary_polygon=[
            (17.065851, 74.275128),
            (17.066405, 74.275018),
            (17.065562, 74.275458),
            (17.065621, 74.275259)
        ]
    ),
    "plot-25": FarmField(
        id="plot-25",
        name="Karkhana Bene Mala - Plot 25",
        name_mr="कारखाना बेणे मळा - Plot 25",
        plot_number="Plot 25",
        area_acres=0.38,
        variety="Phule 265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=305,
        crop_stage="Tillering",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.066153, lng=74.27566),
        boundary_polygon=[
            (17.065664, 74.275543),
            (17.066477, 74.275384),
            (17.066587, 74.27581),
            (17.065886, 74.275904)
        ]
    ),
    "plot-26": FarmField(
        id="plot-26",
        name="Karkhana Bene Mala - Plot 26",
        name_mr="कारखाना बेणे मळा - Plot 26",
        plot_number="Plot 26",
        area_acres=0.28,
        variety="MS 10001",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=310,
        crop_stage="Ripening",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.066323, lng=74.27596),
        boundary_polygon=[
            (17.065876, 74.275896),
            (17.066657, 74.275766),
            (17.066708, 74.276028),
            (17.066052, 74.276151)
        ]
    ),
    "plot-27": FarmField(
        id="plot-27",
        name="Karkhana Bene Mala - Plot 27",
        name_mr="कारखाना बेणे मळा - Plot 27",
        plot_number="Plot 27",
        area_acres=0.23,
        variety="CoM 0265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=315,
        crop_stage="Formative",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.066431, lng=74.27637),
        boundary_polygon=[
            (17.066027, 74.276225),
            (17.066734, 74.27632),
            (17.066757, 74.276412),
            (17.066207, 74.276525)
        ]
    ),
    "plot-28": FarmField(
        id="plot-28",
        name="Karkhana Bene Mala - Plot 28",
        name_mr="कारखाना बेणे मळा - Plot 28",
        plot_number="Plot 28",
        area_acres=0.39,
        variety="Co 86032",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=320,
        crop_stage="Grand Growth",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.066649, lng=74.276809),
        boundary_polygon=[
            (17.066283, 74.276627),
            (17.066758, 74.276456),
            (17.06689, 74.277073),
            (17.066664, 74.277082)
        ]
    ),
    "plot-29": FarmField(
        id="plot-29",
        name="Karkhana Bene Mala - Plot 29",
        name_mr="कारखाना बेणे मळा - Plot 29",
        plot_number="Plot 29",
        area_acres=0.29,
        variety="Phule 265",
        cane_type="Plant cane (Suru)" if False else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=325,
        crop_stage="Tillering",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.067066, lng=74.277607),
        boundary_polygon=[
            (17.066665, 74.277321),
            (17.067235, 74.277167),
            (17.067311, 74.277878),
            (17.067052, 74.278063)
        ]
    ),
    "plot-30": FarmField(
        id="plot-30",
        name="Karkhana Bene Mala - Plot 30",
        name_mr="कारखाना बेणे मळा - Plot 30",
        plot_number="Plot 30",
        area_acres=0.29,
        variety="MS 10001",
        cane_type="Plant cane (Suru)" if True else "Ratoon cane (Khodwa)",
        planting_date="2026-02-02",
        expected_harvest_date="2027-02-02",
        crop_age_days=180,
        crop_stage="Ripening",
        village="राजारामनगर (Rajaramnagar)",
        coordinates=Coordinates(lat=17.067316, lng=74.278395),
        boundary_polygon=[
            (17.066991, 74.278107),
            (17.067291, 74.278029),
            (17.06762, 74.278626),
            (17.067361, 74.278816)
        ]
    )
}


@router.get("", response_model=List[FarmField])
async def list_registered_fields():
    """
    Returns all registered farmer fields in the sugar factory command area.
    """
    return list(FIELDS_DATABASE.values())


@router.get("/{field_id}", response_model=FarmField)
async def get_field_details(field_id: str):
    """
    Returns specific parcel details, boundary coordinates, and crop metadata.
    """
    if field_id not in FIELDS_DATABASE:
        raise HTTPException(status_code=404, detail=f"Field {field_id} not found")
    return FIELDS_DATABASE[field_id]


@router.get("/{field_id}/analysis", response_model=FieldAnalysisResponse)
async def get_field_full_analysis(
    field_id: str,
    date_offset: int = Query(0, ge=0, le=4, description="Historical observation index (0=latest)")
):
    """
    Performs comprehensive multispectral Earth observation analysis:
    - Sentinel-2 Level-2A surface reflectance pixels
    - NDVI (Canopy Growth) and NDMI (Canopy Moisture Signal)
    - Small-parcel resolution analysis and boundary buffer exclusion
    - Real-time Open-Meteo agro-weather context and water balance
    - Dynamic evidence-based advisory
    """
    if field_id not in FIELDS_DATABASE:
        raise HTTPException(status_code=404, detail=f"Field {field_id} not found")

    field = FIELDS_DATABASE[field_id]
    
    # 1. Fetch satellite scenes
    scenes = await search_sentinel_scenes(field.coordinates.lat, field.coordinates.lng)
    scene = scenes[min(date_offset, len(scenes) - 1)]

    # 2. Fetch agro-meteorological data
    weather = await get_weather_for_field(field.coordinates.lat, field.coordinates.lng)

    # 3. Generate calibrated spectral pixels
    pixels = generate_field_pixel_grid(field.id, field.area_acres, date_offset)
    pure_pixels = len([p for p in pixels if not p.is_boundary])

    # 4. Analyze resolution & boundary constraints
    res_analysis = analyze_parcel_resolution(field.area_acres, pure_pixels)

    # 5. Summaries
    valid_pixels = [p for p in pixels if p.is_valid_vegetation and not p.is_boundary]
    if not valid_pixels:
        valid_pixels = pixels

    mean_ndvi = round(sum(p.ndvi for p in valid_pixels) / len(valid_pixels), 3)
    mean_ndmi = round(sum(p.ndmi for p in valid_pixels) / len(valid_pixels), 3)
    mean_ndre = round(sum(p.ndre for p in valid_pixels) / len(valid_pixels), 3)

    spectral_summary = {
        "mean_ndvi": mean_ndvi,
        "mean_ndmi": mean_ndmi,
        "mean_ndre": mean_ndre,
        "total_pixels": len(pixels),
        "usable_pure_pixels": pure_pixels,
        "cloud_masked_pixels": 0
    }

    # 6. Generate dynamic advisory
    advisory = generate_dynamic_advisory(field, pixels, weather)

    # 7. Execute Sugarcane Machine Learning Engines (Yield, Sucrose/Brix, FAO-56 Drip, Anomaly ML)
    yield_pred = SugarcaneMLEngine.predict_yield(field, weather, mean_ndvi, mean_ndre, mean_ndmi)
    sucrose_mat = SugarcaneMLEngine.predict_sucrose_maturity(field, weather, mean_ndvi, mean_ndre, mean_ndmi)
    irrig_rx = SugarcaneMLEngine.calculate_fao56_irrigation(weather, field, mean_ndmi, mean_ndvi)
    anomaly_ml = SugarcaneMLEngine.diagnose_anomalies(mean_ndvi, mean_ndre, mean_ndmi, weather, field)

    return FieldAnalysisResponse(
        field=field,
        satellite_metadata=scene,
        resolution_analysis=res_analysis,
        weather=weather,
        spectral_summary=spectral_summary,
        pixels=pixels,
        advisory=advisory,
        yield_prediction=yield_pred,
        sucrose_maturity=sucrose_mat,
        irrigation_prescription=irrig_rx,
        anomaly_ml=anomaly_ml
    )
