/// Official Hong Kong districts plus informal names used in sample data.
const List<String> kOfficialHongKongDistricts = [
  'Central and Western',
  'Wan Chai',
  'Eastern',
  'Southern',
  'Yau Tsim Mong',
  'Sham Shui Po',
  'Kowloon City',
  'Wong Tai Sin',
  'Kwun Tong',
  'Tsuen Wan',
  'Tuen Mun',
  'Yuen Long',
  'North',
  'Tai Po',
  'Sha Tin',
  'Sai Kung',
  'Islands',
  'Kwai Tsing',
];

/// Informal / neighbourhood labels that appear in seed listings.
const List<String> kInformalHongKongDistricts = [
  'Central',
  'Mong Kok',
];

List<String> allHongKongDistrictChoices() {
  return [...kOfficialHongKongDistricts, ...kInformalHongKongDistricts];
}
