import 'dart:math' as math;
import '../models/field_model.dart';
import '../models/slip_model.dart';
import '../models/learn_model.dart';

class MockData {
  static final List<FarmFieldModel> fields = [
    const FarmFieldModel(
      id: 'plot-1',
      name: 'Karkhana Bene Mala - Plot 1',
      nameMr: 'कारखाना बेणे मळा - Plot 1',
      plotNumber: 'Plot 1',
      areaAcres: 0.15,
      variety: 'Phule 265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 185,
      cropStage: 'Tillering',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.067927,
      lng: 74.274734,
      boundaryPolygon: [
        [17.067526, 74.274479],
        [17.068243, 74.274786],
        [17.068264, 74.274798],
        [17.067676, 74.274872],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-2',
      name: 'Karkhana Bene Mala - Plot 2',
      nameMr: 'कारखाना बेणे मळा - Plot 2',
      plotNumber: 'Plot 2',
      areaAcres: 0.36,
      variety: 'MS 10001',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 190,
      cropStage: 'Ripening',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.068093,
      lng: 74.275045,
      boundaryPolygon: [
        [17.06767, 74.274899],
        [17.068504, 74.274872],
        [17.068491, 74.275176],
        [17.067708, 74.275234],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-3',
      name: 'Karkhana Bene Mala - Plot 3',
      nameMr: 'कारखाना बेणे मळा - Plot 3',
      plotNumber: 'Plot 3',
      areaAcres: 0.3,
      variety: 'CoM 0265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 195,
      cropStage: 'Formative',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.068107,
      lng: 74.275327,
      boundaryPolygon: [
        [17.067743, 74.275231],
        [17.068502, 74.275142],
        [17.068394, 74.275418],
        [17.067788, 74.275516],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-4',
      name: 'Karkhana Bene Mala - Plot 4',
      nameMr: 'कारखाना बेणे मळा - Plot 4',
      plotNumber: 'Plot 4',
      areaAcres: 0.25,
      variety: 'Co 86032',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 200,
      cropStage: 'Grand Growth',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.06816,
      lng: 74.275772,
      boundaryPolygon: [
        [17.067822, 74.275679],
        [17.068519, 74.275591],
        [17.068491, 74.275902],
        [17.067808, 74.275915],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-5',
      name: 'Karkhana Bene Mala - Plot 5',
      nameMr: 'कारखाना बेणे मळा - Plot 5',
      plotNumber: 'Plot 5',
      areaAcres: 0.22,
      variety: 'Phule 265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 205,
      cropStage: 'Tillering',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.068222,
      lng: 74.276122,
      boundaryPolygon: [
        [17.067928, 74.276013],
        [17.068519, 74.275915],
        [17.068508, 74.276249],
        [17.067935, 74.27631],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-6',
      name: 'Karkhana Bene Mala - Plot 6',
      nameMr: 'कारखाना बेणे मळा - Plot 6',
      plotNumber: 'Plot 6',
      areaAcres: 0.18,
      variety: 'MS 10001',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 210,
      cropStage: 'Ripening',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.068244,
      lng: 74.276436,
      boundaryPolygon: [
        [17.06795, 74.276384],
        [17.068526, 74.276179],
        [17.068451, 74.276586],
        [17.068051, 74.276596],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-7',
      name: 'Karkhana Bene Mala - Plot 7',
      nameMr: 'कारखाना बेणे मळा - Plot 7',
      plotNumber: 'Plot 7',
      areaAcres: 0.14,
      variety: 'CoM 0265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 215,
      cropStage: 'Formative',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.068344,
      lng: 74.277214,
      boundaryPolygon: [
        [17.068146, 74.277119],
        [17.068475, 74.276992],
        [17.06852, 74.277283],
        [17.068235, 74.277461],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-8',
      name: 'Karkhana Bene Mala - Plot 8',
      nameMr: 'कारखाना बेणे मळा - Plot 8',
      plotNumber: 'Plot 8',
      areaAcres: 0.15,
      variety: 'Co 86032',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 220,
      cropStage: 'Grand Growth',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.068424,
      lng: 74.277528,
      boundaryPolygon: [
        [17.068193, 74.277437],
        [17.068532, 74.277347],
        [17.068683, 74.277623],
        [17.068286, 74.277704],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-9',
      name: 'Karkhana Bene Mala - Plot 9',
      nameMr: 'कारखाना बेणे मळा - Plot 9',
      plotNumber: 'Plot 9',
      areaAcres: 0.15,
      variety: 'Phule 265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 225,
      cropStage: 'Tillering',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.068504,
      lng: 74.27783,
      boundaryPolygon: [
        [17.068245, 74.277748],
        [17.068666, 74.277684],
        [17.06875, 74.277875],
        [17.068355, 74.278014],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-10',
      name: 'Karkhana Bene Mala - Plot 10',
      nameMr: 'कारखाना बेणे मळा - Plot 10',
      plotNumber: 'Plot 10',
      areaAcres: 0.19,
      variety: 'MS 10001',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 230,
      cropStage: 'Ripening',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.068612,
      lng: 74.278202,
      boundaryPolygon: [
        [17.068359, 74.278043],
        [17.068792, 74.27796],
        [17.068822, 74.278316],
        [17.068476, 74.27849],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-11',
      name: 'Karkhana Bene Mala - Plot 11',
      nameMr: 'कारखाना बेणे मळा - Plot 11',
      plotNumber: 'Plot 11',
      areaAcres: 0.28,
      variety: 'CoM 0265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 235,
      cropStage: 'Formative',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.067966,
      lng: 74.278372,
      boundaryPolygon: [
        [17.067546, 74.278258],
        [17.068297, 74.278163],
        [17.068335, 74.278496],
        [17.067686, 74.27857],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-12',
      name: 'Karkhana Bene Mala - Plot 12',
      nameMr: 'कारखाना बेणे मळा - Plot 12',
      plotNumber: 'Plot 12',
      areaAcres: 0.29,
      variety: 'Co 86032',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 240,
      cropStage: 'Grand Growth',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.067861,
      lng: 74.278073,
      boundaryPolygon: [
        [17.067392, 74.278058],
        [17.068198, 74.277791],
        [17.068291, 74.278126],
        [17.067561, 74.278316],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-13',
      name: 'Karkhana Bene Mala - Plot 13',
      nameMr: 'कारखाना बेणे मळा - Plot 13',
      plotNumber: 'Plot 13',
      areaAcres: 0.31,
      variety: 'Phule 265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 245,
      cropStage: 'Tillering',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.067723,
      lng: 74.277745,
      boundaryPolygon: [
        [17.067202, 74.277723],
        [17.06813, 74.277453],
        [17.068204, 74.277785],
        [17.067358, 74.27802],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-14',
      name: 'Karkhana Bene Mala - Plot 14',
      nameMr: 'कारखाना बेणे मळा - Plot 14',
      plotNumber: 'Plot 14',
      areaAcres: 0.48,
      variety: 'MS 10001',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 250,
      cropStage: 'Ripening',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.067597,
      lng: 74.277292,
      boundaryPolygon: [
        [17.067034, 74.277216],
        [17.068038, 74.276943],
        [17.06812, 74.277375],
        [17.067195, 74.277634],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-15',
      name: 'Karkhana Bene Mala - Plot 15',
      nameMr: 'कारखाना बेणे मळा - Plot 15',
      plotNumber: 'Plot 15',
      areaAcres: 0.57,
      variety: 'CoM 0265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 255,
      cropStage: 'Formative',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.067438,
      lng: 74.276667,
      boundaryPolygon: [
        [17.066916, 74.276476],
        [17.067878, 74.276394],
        [17.067999, 74.276773],
        [17.06696, 74.277026],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-16',
      name: 'Karkhana Bene Mala - Plot 16',
      nameMr: 'कारखाना बेणे मळा - Plot 16',
      plotNumber: 'Plot 16',
      areaAcres: 0.38,
      variety: 'Co 86032',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 260,
      cropStage: 'Grand Growth',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.067315,
      lng: 74.276252,
      boundaryPolygon: [
        [17.06674, 74.276101],
        [17.067772, 74.276094],
        [17.067835, 74.276331],
        [17.066913, 74.27648],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-17',
      name: 'Karkhana Bene Mala - Plot 17',
      nameMr: 'कारखाना बेणे मळा - Plot 17',
      plotNumber: 'Plot 17',
      areaAcres: 0.35,
      variety: 'Phule 265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 265,
      cropStage: 'Tillering',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.067211,
      lng: 74.275891,
      boundaryPolygon: [
        [17.066652, 74.275812],
        [17.067694, 74.275691],
        [17.067737, 74.276002],
        [17.066759, 74.276059],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-18',
      name: 'Karkhana Bene Mala - Plot 18',
      nameMr: 'कारखाना बेणे मळा - Plot 18',
      plotNumber: 'Plot 18',
      areaAcres: 0.32,
      variety: 'MS 10001',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 270,
      cropStage: 'Ripening',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.067173,
      lng: 74.275552,
      boundaryPolygon: [
        [17.066686, 74.27541],
        [17.06762, 74.275407],
        [17.067693, 74.275622],
        [17.066695, 74.27577],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-19',
      name: 'Karkhana Bene Mala - Plot 19',
      nameMr: 'कारखाना बेणे मळा - Plot 19',
      plotNumber: 'Plot 19',
      areaAcres: 0.38,
      variety: 'CoM 0265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 275,
      cropStage: 'Formative',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.06709,
      lng: 74.275164,
      boundaryPolygon: [
        [17.066558, 74.275064],
        [17.067553, 74.27494],
        [17.067588, 74.27527],
        [17.06666, 74.275383],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-20',
      name: 'Karkhana Bene Mala - Plot 20',
      nameMr: 'कारखाना बेणे मळा - Plot 20',
      plotNumber: 'Plot 20',
      areaAcres: 0.32,
      variety: 'Co 86032',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 280,
      cropStage: 'Grand Growth',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.067017,
      lng: 74.274796,
      boundaryPolygon: [
        [17.066498, 74.274727],
        [17.067451, 74.274599],
        [17.067551, 74.274878],
        [17.066566, 74.274979],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-21',
      name: 'Karkhana Bene Mala - Plot 21',
      nameMr: 'कारखाना बेणे मळा - Plot 21',
      plotNumber: 'Plot 21',
      areaAcres: 0.4,
      variety: 'Phule 265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 285,
      cropStage: 'Tillering',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.066911,
      lng: 74.27448,
      boundaryPolygon: [
        [17.066317, 74.274158],
        [17.067412, 74.274518],
        [17.06744, 74.27458],
        [17.066477, 74.274663],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-22',
      name: 'Karkhana Bene Mala - Plot 22',
      nameMr: 'कारखाना बेणे मळा - Plot 22',
      plotNumber: 'Plot 22',
      areaAcres: 0.38,
      variety: 'MS 10001',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 290,
      cropStage: 'Ripening',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.065917,
      lng: 74.274224,
      boundaryPolygon: [
        [17.065424, 74.273952],
        [17.066163, 74.274094],
        [17.066333, 74.274459],
        [17.065749, 74.27439],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-23',
      name: 'Karkhana Bene Mala - Plot 23',
      nameMr: 'कारखाना बेणे मळा - Plot 23',
      plotNumber: 'Plot 23',
      areaAcres: 0.37,
      variety: 'CoM 0265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 295,
      cropStage: 'Formative',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.066123,
      lng: 74.274769,
      boundaryPolygon: [
        [17.06579, 74.274582],
        [17.06625, 74.274467],
        [17.066412, 74.274997],
        [17.06604, 74.275032],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-24',
      name: 'Karkhana Bene Mala - Plot 24',
      nameMr: 'कारखाना बेणे मळा - Plot 24',
      plotNumber: 'Plot 24',
      areaAcres: 0.33,
      variety: 'Co 86032',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 300,
      cropStage: 'Grand Growth',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.06586,
      lng: 74.275216,
      boundaryPolygon: [
        [17.065851, 74.275128],
        [17.066405, 74.275018],
        [17.065562, 74.275458],
        [17.065621, 74.275259],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-25',
      name: 'Karkhana Bene Mala - Plot 25',
      nameMr: 'कारखाना बेणे मळा - Plot 25',
      plotNumber: 'Plot 25',
      areaAcres: 0.38,
      variety: 'Phule 265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 305,
      cropStage: 'Tillering',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.066153,
      lng: 74.27566,
      boundaryPolygon: [
        [17.065664, 74.275543],
        [17.066477, 74.275384],
        [17.066587, 74.27581],
        [17.065886, 74.275904],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-26',
      name: 'Karkhana Bene Mala - Plot 26',
      nameMr: 'कारखाना बेणे मळा - Plot 26',
      plotNumber: 'Plot 26',
      areaAcres: 0.28,
      variety: 'MS 10001',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 310,
      cropStage: 'Ripening',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.066323,
      lng: 74.27596,
      boundaryPolygon: [
        [17.065876, 74.275896],
        [17.066657, 74.275766],
        [17.066708, 74.276028],
        [17.066052, 74.276151],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-27',
      name: 'Karkhana Bene Mala - Plot 27',
      nameMr: 'कारखाना बेणे मळा - Plot 27',
      plotNumber: 'Plot 27',
      areaAcres: 0.23,
      variety: 'CoM 0265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 315,
      cropStage: 'Formative',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.066431,
      lng: 74.27637,
      boundaryPolygon: [
        [17.066027, 74.276225],
        [17.066734, 74.27632],
        [17.066757, 74.276412],
        [17.066207, 74.276525],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-28',
      name: 'Karkhana Bene Mala - Plot 28',
      nameMr: 'कारखाना बेणे मळा - Plot 28',
      plotNumber: 'Plot 28',
      areaAcres: 0.39,
      variety: 'Co 86032',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 320,
      cropStage: 'Grand Growth',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.066649,
      lng: 74.276809,
      boundaryPolygon: [
        [17.066283, 74.276627],
        [17.066758, 74.276456],
        [17.06689, 74.277073],
        [17.066664, 74.277082],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-29',
      name: 'Karkhana Bene Mala - Plot 29',
      nameMr: 'कारखाना बेणे मळा - Plot 29',
      plotNumber: 'Plot 29',
      areaAcres: 0.29,
      variety: 'Phule 265',
      caneType: 'Ratoon cane (Khodwa)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 325,
      cropStage: 'Tillering',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.067066,
      lng: 74.277607,
      boundaryPolygon: [
        [17.066665, 74.277321],
        [17.067235, 74.277167],
        [17.067311, 74.277878],
        [17.067052, 74.278063],
      ],
    ),
    const FarmFieldModel(
      id: 'plot-30',
      name: 'Karkhana Bene Mala - Plot 30',
      nameMr: 'कारखाना बेणे मळा - Plot 30',
      plotNumber: 'Plot 30',
      areaAcres: 0.29,
      variety: 'MS 10001',
      caneType: 'Plant cane (Suru)',
      plantingDate: '2026-02-02',
      expectedHarvestDate: '2027-02-02',
      cropAgeDays: 180,
      cropStage: 'Ripening',
      village: 'राजारामनगर (Rajaramnagar)',
      lat: 17.067316,
      lng: 74.278395,
      boundaryPolygon: [
        [17.066991, 74.278107],
        [17.067291, 74.278029],
        [17.06762, 74.278626],
        [17.067361, 74.278816],
      ],
    )
  ];

  static List<PixelModel> getPixelsForPlot30(int dateOffset) {
    final List<PixelModel> list = [];
    final offsets = [0.0, 0.03, 0.06, 0.09, 0.12];
    final off = offsets[dateOffset.clamp(0, 4)];

    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 6; c++) {
        final isBoundary = (r == 0 || r == 3 || c == 0 || c == 5);
        final isNW = (r <= 1 && c <= 2);

        final double ndvi = isNW ? (0.28 + off) : (0.44 + off);
        final double ndmi = isNW ? (-0.14 + off * 0.5) : (0.06 + off * 0.4);

        list.add(PixelModel(
          id: 'p30-r$r-c$c',
          col: c,
          row: r,
          ndvi: double.parse(ndvi.toStringAsFixed(3)),
          ndmi: double.parse(ndmi.toStringAsFixed(3)),
          ndre: double.parse((ndvi * 0.85).toStringAsFixed(3)),
          isValidVegetation: true,
          isBoundary: isBoundary,
          classification: ndvi < 0.35 ? 'Stressed / Less Growth' : 'Moderate Growth',
        ));
      }
    }
    return list;
  }

  static List<PixelModel> getPixelsForPlot5(int dateOffset) {
    return getPixelsForField(MockData.fields.firstWhere((f) => f.id == 'plot-5', orElse: () => MockData.fields.first), dateOffset);
  }

  static List<PixelModel> getPixelsForField(FarmFieldModel field, int dateOffset) {
    if (field.id == 'plot-30') return getPixelsForPlot30(dateOffset);

    int plotNum = 1;
    final match = RegExp(r'plot-(\d+)').firstMatch(field.id);
    if (match != null) {
      plotNum = int.tryParse(match.group(1) ?? '1') ?? 1;
    }

    final area = field.areaAcres;
    int rows = 4;
    int cols = 3;
    if (area <= 0.20) {
      rows = 3;
      cols = 3;
    } else if (area <= 0.35) {
      rows = 4;
      cols = 3;
    } else if (area <= 0.50) {
      rows = 5;
      cols = 3;
    } else if (area <= 0.70) {
      rows = 5;
      cols = 4;
    } else if (area <= 0.90) {
      rows = 6;
      cols = 4;
    } else {
      rows = 6;
      cols = 5;
    }

    final archetype = plotNum % 5;
    final stressR = (plotNum * 2) % rows;
    final stressC = (plotNum * 3) % cols;

    double baseNdvi = 0.78;
    double baseNdmi = 0.28;
    if (archetype == 1) {
      baseNdvi = 0.58;
      baseNdmi = 0.12;
    } else if (archetype == 2) {
      baseNdvi = 0.65;
      baseNdmi = 0.14;
    } else if (archetype == 3) {
      baseNdvi = 0.54;
      baseNdmi = 0.22;
    } else if (archetype == 4) {
      baseNdvi = 0.62;
      baseNdmi = 0.19;
    }

    final List<PixelModel> list = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final isBoundary = (r == 0 || r == rows - 1 || c == 0 || c == cols - 1);
        final dist = math.sqrt(math.pow(r - stressR, 2) + math.pow(c - stressC, 2)) /
            math.max(1.0, math.sqrt(math.pow(rows, 2) + math.pow(cols, 2)));

        double localNdvi = baseNdvi;
        double localNdmi = baseNdmi;

        if (archetype == 1) {
          final sf = (1.0 - (dist * 2.2)).clamp(0.0, 1.0);
          localNdvi = (baseNdvi - sf * 0.30).clamp(0.26, 0.90);
          localNdmi = (baseNdmi - sf * 0.32).clamp(-0.20, 0.45);
        } else if (archetype == 3) {
          final sf = (c == cols ~/ 2) ? 1.0 : 0.2;
          localNdvi = (baseNdvi - sf * 0.16).clamp(0.30, 0.90);
          localNdmi = (baseNdmi + (r % 2) * 0.03).clamp(-0.10, 0.45);
        } else if (archetype == 4) {
          final isPatch = (r == stressR && c == stressC);
          final sf = isPatch ? 0.85 : 0.0;
          localNdvi = (baseNdvi - sf * 0.28).clamp(0.28, 0.90);
          localNdmi = (baseNdmi - sf * 0.12).clamp(-0.10, 0.45);
        } else {
          final wave = math.sin((r * 0.8) + (c * 0.5) + plotNum) * 0.05;
          localNdvi = (baseNdvi + wave).clamp(0.40, 0.88);
          localNdmi = (baseNdmi + wave * 0.6).clamp(0.05, 0.40);
        }

        final double ndre = (localNdvi * (archetype == 3 ? 0.55 : 0.88)).clamp(0.12, 0.65);

        list.add(PixelModel(
          id: '${field.id}-r$r-c$c',
          col: c,
          row: r,
          ndvi: double.parse(localNdvi.toStringAsFixed(3)),
          ndmi: double.parse(localNdmi.toStringAsFixed(3)),
          ndre: double.parse(ndre.toStringAsFixed(3)),
          isValidVegetation: true,
          isBoundary: isBoundary,
          classification: localNdvi >= 0.70
              ? 'Dense Growth'
              : (localNdvi >= 0.50 ? 'Moderate Growth' : 'Stressed / Transition'),
        ));
      }
    }
    return list;
  }

  static ResolutionAnalysisModel getResolutionForField(FarmFieldModel field) {
    if (field.id == 'plot-30') {
      return const ResolutionAnalysisModel(
        areaAcres: 0.59,
        areaSqMeters: 2387.65,
        theoretical10mPixels: 23,
        theoretical20mPixels: 5,
        usablePurePixels: 8,
        boundaryExcludedPixels: 15,
        usabilityRatio: 0.35,
        resolutionRating: 'Constrained',
        droneSurveyRecommended: true,
        limitationNotice: 'Plot area (0.59 acres) yields only 8 pure pixels. Sentinel-2 20m SWIR bands give approx 5-6 pixels. Within-field zoning is indicative; recommend factory drone survey for fine micro-zoning.',
      );
    } else {
      return const ResolutionAnalysisModel(
        areaAcres: 1.08,
        areaSqMeters: 4370.61,
        theoretical10mPixels: 43,
        theoretical20mPixels: 10,
        usablePurePixels: 24,
        boundaryExcludedPixels: 19,
        usabilityRatio: 0.56,
        resolutionRating: 'Acceptable',
        droneSurveyRecommended: false,
        limitationNotice: '43 theoretical pixels available. Boundary erosion buffer applied to suppress perimeter tree and road spectral bleeding.',
      );
    }
  }

  static DynamicAdvisoryModel getAdvisoryForField(FarmFieldModel field) {
    if (field.id == 'plot-30') {
      return const DynamicAdvisoryModel(
        statusLevel: 'inspect',
        headline: 'Inspect North-West sector: Growth and canopy water signal drop detected',
        detail: 'Mean NDVI dropped by 24% over the last 15 days in the western 0.22 acres. Canopy moisture signal (NDMI = -0.06) indicates localized physiological stress.',
        affectedSector: 'North-West sector (Rows 1 to 14)',
        confidencePct: 84,
        differentialDiagnosis: [
          'Early Shoot Borer or Internode Borer (check for dead-hearts in central cane whorls)',
          'Drip lateral clogging or sub-main pressure drop along North boundary',
          'Localized salinity or soil compaction restricting root water uptake'
        ],
        suggestedActions: [
          'Physically walk the North-West rows; inspect 20 sample cane stalks for boreholes or frass before applying any chemical spray.',
          'Flush drip laterals and inspect emitter discharge rate along sub-main 1.',
          'Confirm root-zone soil moisture with an auger before irrigating; spectral signal measures leaf hydration, not root-zone water content.',
          'If pest symptoms are confirmed, book factory multispectral drone or consult Cane Inspector D. B. Patil.'
        ],
        scientificDisclaimer: 'Sentinel-2 spectral indices measure canopy reflection (chlorophyll and leaf water content). They are indicative screening tools, not laboratory diagnoses of pests or root-zone water.',
      );
    } else {
      return const DynamicAdvisoryModel(
        statusLevel: 'good',
        headline: 'Cane maturing well: Uniform green canopy across 90% of field',
        detail: 'High average NDVI (0.74) and positive NDMI (0.28) confirm vigorous canopy. Recent 7-day rainfall (6.3mm) and ET0 (4.6mm/day) indicate balanced crop hydration.',
        affectedSector: 'Central pocket (minor maturity variance)',
        confidencePct: 92,
        differentialDiagnosis: [
          'Natural physiological leaf desiccation during sucrose accumulation (pre-harvest maturity phase)',
          'Mild micro-nutrient variation in central depression'
        ],
        suggestedActions: [
          'Maintain scheduled pre-harvest irrigation withdrawal as per factory slip date.',
          'Avoid late nitrogen fertilizer application to preserve cane sugar recovery percentage.',
          'Field is on schedule for factory harvesting authorization.'
        ],
        scientificDisclaimer: 'Satellite indices confirm healthy vegetative foliage. Cane tonnage and sugar recovery must be calibrated via pre-harvest field brix sampling.',
      );
    }
  }

  static const List<HarvestingSlipModel> slips = [
    HarvestingSlipModel(
      slipId: 'SC-00000002',
      regId: 'CR-00000002',
      season: '2026–27',
      farmerName: 'Karkhana Bene Mala (Nursery)',
      farmerNameMr: 'कारखाना बेणे मळा (Nursery)',
      plotName: 'कारखाना बेणे मळा नं.1 - Plot 2',
      village: 'राजारामनगर',
      caneType: 'Plant cane',
      variety: 'Co 86032',
      registeredAreaAcres: 0.36,
      plantingDate: '2 Feb 2026',
      harvestingDate: '2 Feb 2027',
      estimatedTonnes: 14.0,
      method: 'Manual',
      status: 'Slip issued',
      registeredAt: '15/10/2026, 1:45:51 am',
      issuedAt: '15/10/2026, 1:47:21 am',
      assignedOfficer: 'Factory admin (D. B. Patil)',
      remarks: 'Nursery plot with seasonal planning. Estimated tonnage requires field confirmation before cutting.',
      qrPayload: 'BHOOMIIQ:SLIP:SC-00000002|REG:CR-00000002|PLOT:P2|EXP:14.0T|DATE:2027-02-02|SIG:d93bbecbc1b3dfa6',
    ),
    HarvestingSlipModel(
      slipId: 'SC-00000005',
      regId: 'CR-00000005',
      season: '2026–27',
      farmerName: 'Shri. Babaso Patil',
      farmerNameMr: 'श्री. बाबासो पाटील',
      plotName: 'कारखाना बेणे मळा नं. 2 - Plot 5',
      village: 'राजारामनगर',
      caneType: 'Ratoon cane (Khodwa)',
      variety: 'Phule 265',
      registeredAreaAcres: 1.08,
      plantingDate: '15 Oct 2025',
      harvestingDate: '10 Nov 2026',
      estimatedTonnes: 52.0,
      method: 'Harvester',
      status: 'Approved',
      registeredAt: '10/10/2026, 11:20:00 am',
      issuedAt: '12/10/2026, 3:15:30 pm',
      assignedOfficer: 'Field Inspector S. K. More',
      remarks: 'Pre-harvest brix reading scheduled on 1 Nov. Transport route via Main Factory Bypass.',
      qrPayload: 'BHOOMIIQ:SLIP:SC-00000005|REG:CR-00000005|PLOT:P5|EXP:52.0T|DATE:2026-11-10|SIG:0a12e345b678c901',
    ),
  ];

  static const List<AgronomicGuideModel> guides = [
    AgronomicGuideModel(
      id: 'g-1',
      stage: 'After harvest',
      stageMr: 'कापणीनंतर',
      title: 'Trash Management & Mulching',
      titleMr: 'पाचट व्यवस्थापन आणि नियोजन',
      summary: 'Manage sugarcane trash by shredding or mulching across alternate furrows. Apply decomposing fungus to accelerate nutrient recycling.',
      summaryMr: 'ऊस पाचट जाळण्याऐवजी पाचट कुट्टी मशीनद्वारे सरीमध्ये दाबून ठेवावे. पाचट कुजवणारे जिवाणू वापरावेत.',
      category: 'Harvest',
      dosages: [
        'Decomposing Culture: 2 kg per acre with 80 kg Single Super Phosphate',
        'Urea: 25 kg per acre to balance C:N ratio'
      ],
      safetyNotes: 'Never burn trash in field; burning kills earthworms and degrades topsoil organic carbon.',
    ),
    AgronomicGuideModel(
      id: 'g-2',
      stage: 'General guidance',
      stageMr: 'सर्वसाधारण मार्गदर्शन',
      title: 'Co 86032 Variety Characteristics',
      titleMr: 'को. ८६०३२ वाण संपूर्ण माहिती',
      summary: 'Co 86032 (Nira) is an early-mid maturity miracle cane known for high sugar recovery and excellent ratoonability across Southern Maharashtra.',
      summaryMr: 'को. ८६०३२ हा वाण उच्च साखर उतारा, दुष्काळ प्रतिकारक्षमता आणि उत्तम खोडवा क्षमतेसाठी अत्यंत प्रसिद्ध आहे.',
      category: 'Seed',
      dosages: [
        'Adsali Season: Maturity 15-18 months',
        'Suru / Pre-seasonal: Maturity 12-14 months'
      ],
    ),
    AgronomicGuideModel(
      id: 'g-3',
      stage: 'Before planting',
      stageMr: 'लागवडीपूर्वी',
      title: 'Soil & Water Quality Diagnostic',
      titleMr: 'माती व पाणी परीक्षण',
      summary: 'Collect composite soil samples from 0-30 cm depth. Test electrical conductivity (EC), pH, and organic carbon before cane seed selection.',
      summaryMr: 'लागवडीपूर्वी मातीचे नमुने घेऊन खत मात्रांचे नियोजन करा. जमिनीतील सेंद्रिय कर्ब व क्षारता तपासा.',
      category: 'Soil',
      dosages: [],
    ),
    AgronomicGuideModel(
      id: 'g-4',
      stage: '2 days after planting',
      stageMr: 'लागवडीनंतर २ दिवस',
      title: 'Seed Treatment Protocol',
      titleMr: 'बेणे प्रक्रिया पद्धत',
      summary: 'Dip cane setts for 10-15 minutes in fungicide solution before planting to prevent Pineapple Disease and Smut.',
      summaryMr: 'ऊस बेणे १०-१५ मिनिटे बुरशीनाशक द्रावणात बुडवून लागवड करावी जेणेकरून काणी व कुजव्या रोगाचा प्रादुर्भाव टळतो.',
      category: 'Seed',
      dosages: [
        'Carbendazim (Bavistin): 3 g (or 3 ml) per litre of clean water',
        'Chlorpyrifos: 2 ml per litre if termite infestation is historically present'
      ],
      safetyNotes: 'Wear rubber gloves and protective goggles while treating setts.',
    ),
    AgronomicGuideModel(
      id: 'g-5',
      stage: 'General guidance',
      stageMr: 'सर्वसाधारण मार्गदर्शन',
      title: 'Phule 265 Variety Characteristics',
      titleMr: 'फुले २६५ वाण माहिती',
      summary: 'Phule 265 is a high-yielding, thick cane variety well-adapted to saline soils and heavy soils with exceptional tonnage potential.',
      summaryMr: 'क्षारपड व भारी जमिनीतही भरघोस उत्पादन देणारा जाड कांड्यांचा वाण.',
      category: 'Seed',
      dosages: [],
    ),
    AgronomicGuideModel(
      id: 'g-6',
      stage: '10 days after harvest',
      stageMr: 'तोडणीनंतर १० दिवस',
      title: 'Trash Mulching & Super Phosphate',
      titleMr: 'पाचट आच्छादन व सुपर फॉस्फेट',
      summary: 'Broadcast single super phosphate (SSP) over shredded trash to provide phosphorus for tillering and microbial digestion.',
      summaryMr: 'पाचटावर २ पोती सिंगल सुपर फॉस्फेट आणि १ पोते युरिया समप्रमाणात टाकावे.',
      category: 'Nutrition',
      dosages: [
        'Single Super Phosphate: 2 bags (100 kg) per acre',
        'Urea: 1 bag (45 kg) per acre'
      ],
    ),
  ];

  static const List<FactorySchemeModel> schemes = [
    FactorySchemeModel(
      id: 'scheme-drip',
      title: 'Factory Drip Irrigation Incentive Scheme',
      titleMr: 'ठिबक सिंचन कारखाना अनुदान योजना',
      benefit: '10% Factory Subsidy over Government Subsidy + ₹5,000 per acre bonus',
      benefitMr: 'शासकीय अनुदानाव्यतिरिक्त १०% कारखाना अनुदान + ₹५,००० प्रति एकर',
      eligibility: 'Registered sugarcane farmer members of Rajarambapu Patil SSK with active field registration.',
      eligibilityMr: 'कारखान्याचे नोंदणीकृत शेतकरी सभासद, ज्यांची ऊस नोंद सक्रिय आहे.',
      contactName: 'Agriculture Extension Wing',
      contactPhone: '+91 2342 220455',
    ),
    FactorySchemeModel(
      id: 'scheme-drainage',
      title: 'Rajaram Bapu Subsurface Drainage Scheme',
      titleMr: 'राजारामबापू भूगर्भीय निचरा प्रणाली योजना',
      benefit: 'Subsurface corrugated perforated pipe drainage with interest-free factory credit loan of ₹4,000/acre',
      benefitMr: 'क्षारपड व पाणथळ जमिनीसाठी बिनव्याजी ₹४,००० प्रति एकर कर्ज व तांत्रिक मार्गदर्शन',
      eligibility: 'Farmer members whose fields suffer from salinity, high water table, or waterlogging.',
      eligibilityMr: 'पाणथळ किंवा क्षारयुक्त जमीन असलेले सभासद शेतकरी.',
      contactName: 'Land Development Cell',
      contactPhone: '+91 2342 220459',
    ),
    FactorySchemeModel(
      id: 'scheme-compost',
      title: 'Factory Press Mud & Enriched Bio-compost',
      titleMr: 'कारखाना मळी व समृद्ध कंपोस्ट खत योजना',
      benefit: 'Subsidized factory press mud delivered directly to field at ₹450 per tonne',
      benefitMr: 'सेंद्रिय कर्ब वाढीसाठी नाममात्र दरात थेट शेतावर मळी कंपोस्ट खत पोहोच',
      eligibility: 'All registered farmers preparing land for adsali or suru cane planting.',
      eligibilityMr: 'नवीन लागवड करणारे सर्व ऊस उत्पादक शेतकरी.',
      contactName: 'By-Products Division',
      contactPhone: '+91 2342 220462',
    ),
  ];

  static const List<FactoryFacilityModel> facilities = [
    FactoryFacilityModel(
      id: 'fac-drone-camera',
      title: 'Multispectral Drone Imagery Survey',
      titleMr: 'मल्टीस्पेक्ट्रल ड्रोन कॅमेरा सर्वेक्षण',
      department: 'Agriculture Department',
      departmentMr: 'कृषी विभाग',
      description: 'Ultra-high 5cm resolution 5-band multispectral survey generating calibrated NDVI, NDRE, and canopy height maps for micro-zoning sub-acre plots.',
      descriptionMr: 'अत्याधुनिक ५-बँड ड्रोनद्वारे शेताचे सूक्ष्म सर्वेक्षण. NDVI व पानांमधील अन्नद्रव्य कमतरतेचे अचूक विश्लेषण.',
      leadTime: 'Survey completed within 48 hours of booking',
      contactPhone: '+91 98224 56789',
    ),
    FactoryFacilityModel(
      id: 'fac-soil-lab',
      title: 'Central Soil & Water Testing Laboratory',
      titleMr: 'मध्यवर्ती माती व पाणी परीक्षण केंद्र',
      department: 'Factory Headquarters, Rajaramnagar',
      departmentMr: 'कारखाना मुख्यालय, राजारामनगर',
      description: 'ISO-calibrated wet-chemistry testing of N, P, K, pH, Electrical Conductivity (EC), Organic Carbon, Zinc, and Iron with digitized fertilizer recommendations.',
      descriptionMr: 'एनपीके, सामू (pH), क्षारता, सेंद्रिय कर्ब व सूक्ष्म अन्नद्रव्यांची अचूक प्रयोगशाळा चाचणी व खत मात्रा कार्ड.',
      leadTime: 'Digital report delivered to BhoomiIQ app within 4 days',
      contactPhone: '+91 2342 220470',
    ),
    FactoryFacilityModel(
      id: 'fac-drone-spray',
      title: 'Precision Drone Spraying Fleet',
      titleMr: 'ड्रोन फवारणी सेवा केंद्र',
      department: 'Cane Protection Division',
      departmentMr: 'ऊस संरक्षण विभाग',
      description: 'Fleet of 10L/16L agricultural drones for uniform micronutrient, bio-stimulant, or approved fungicide spraying across tall mature sugarcane canopies without trampling.',
      descriptionMr: 'मोठ्या वाढलेल्या उसातही पिकाचे नुकसान न होता समान व जलद सूक्ष्म अन्नद्रव्य किंवा औषध फवारणी (२०२१ पासून कार्यरत).',
      leadTime: 'Slot confirmed within 24 hours',
      contactPhone: '+91 98224 56790',
    ),
  ];
}
