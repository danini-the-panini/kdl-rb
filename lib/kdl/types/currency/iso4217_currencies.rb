# frozen_string_literal: true

module KDL
  module Types
    class Currency < Value::Custom
      # From https://en.wikipedia.org/wiki/ISO_4217#Active_codes
      CURRENCIES = {
        'AED' => { numeric_code: 784, minor_unit: 2, name: 'United Arab Emirates dirham' }.freeze,
        'AFN' => { numeric_code: 971, minor_unit: 2, name: 'Afghan afghani' }.freeze,
        'ALL' => { numeric_code: 8, minor_unit: 2, name: 'Albanian lek' }.freeze,
        'AMD' => { numeric_code: 51, minor_unit: 2, name: 'Armenian dram' }.freeze,
        'ANG' => { numeric_code: 532, minor_unit: 2, name: 'Netherlands Antillean guilder' }.freeze,
        'AOA' => { numeric_code: 973, minor_unit: 2, name: 'Angolan kwanza' }.freeze,
        'ARS' => { numeric_code: 32, minor_unit: 2, name: 'Argentine peso' }.freeze,
        'AUD' => { numeric_code: 36, minor_unit: 2, name: 'Australian dollar' }.freeze,
        'AWG' => { numeric_code: 533, minor_unit: 2, name: 'Aruban florin' }.freeze,
        'AZN' => { numeric_code: 944, minor_unit: 2, name: 'Azerbaijani manat' }.freeze,
        'BAM' => { numeric_code: 977, minor_unit: 2, name: 'Bosnia and Herzegovina convertible mark' }.freeze,
        'BBD' => { numeric_code: 52, minor_unit: 2, name: 'Barbados dollar' }.freeze,
        'BDT' => { numeric_code: 50, minor_unit: 2, name: 'Bangladeshi taka' }.freeze,
        'BGN' => { numeric_code: 975, minor_unit: 2, name: 'Bulgarian lev' }.freeze,
        'BHD' => { numeric_code: 48, minor_unit: 3, name: 'Bahraini dinar' }.freeze,
        'BIF' => { numeric_code: 108, minor_unit: 0, name: 'Burundian franc' }.freeze,
        'BMD' => { numeric_code: 60, minor_unit: 2, name: 'Bermudian dollar' }.freeze,
        'BND' => { numeric_code: 96, minor_unit: 2, name: 'Brunei dollar' }.freeze,
        'BOB' => { numeric_code: 68, minor_unit: 2, name: 'Boliviano' }.freeze,
        'BOV' => { numeric_code: 984, minor_unit: 2, name: 'Bolivian Mvdol (funds code)' }.freeze,
        'BRL' => { numeric_code: 986, minor_unit: 2, name: 'Brazilian real' }.freeze,
        'BSD' => { numeric_code: 44, minor_unit: 2, name: 'Bahamian dollar' }.freeze,
        'BTN' => { numeric_code: 64, minor_unit: 2, name: 'Bhutanese ngultrum' }.freeze,
        'BWP' => { numeric_code: 72, minor_unit: 2, name: 'Botswana pula' }.freeze,
        'BYN' => { numeric_code: 933, minor_unit: 2, name: 'Belarusian ruble' }.freeze,
        'BZD' => { numeric_code: 84, minor_unit: 2, name: 'Belize dollar' }.freeze,
        'CAD' => { numeric_code: 124, minor_unit: 2, name: 'Canadian dollar' }.freeze,
        'CDF' => { numeric_code: 976, minor_unit: 2, name: 'Congolese franc' }.freeze,
        'CHE' => { numeric_code: 947, minor_unit: 2, name: 'WIR euro (complementary currency)' }.freeze,
        'CHF' => { numeric_code: 756, minor_unit: 2, name: 'Swiss franc' }.freeze,
        'CHW' => { numeric_code: 948, minor_unit: 2, name: 'WIR franc (complementary currency)' }.freeze,
        'CLF' => { numeric_code: 990, minor_unit: 4, name: 'Unidad de Fomento (funds code)' }.freeze,
        'CLP' => { numeric_code: 152, minor_unit: 0, name: 'Chilean peso' }.freeze,
        'CNY' => { numeric_code: 156, minor_unit: 2, name: 'Chinese yuan[8]' }.freeze,
        'COP' => { numeric_code: 170, minor_unit: 2, name: 'Colombian peso' }.freeze,
        'COU' => { numeric_code: 970, minor_unit: 2, name: 'Unidad de Valor Real (UVR) (funds code)' }.freeze,
        'CRC' => { numeric_code: 188, minor_unit: 2, name: 'Costa Rican colon' }.freeze,
        'CUC' => { numeric_code: 931, minor_unit: 2, name: 'Cuban convertible peso' }.freeze,
        'CUP' => { numeric_code: 192, minor_unit: 2, name: 'Cuban peso' }.freeze,
        'CVE' => { numeric_code: 132, minor_unit: 2, name: 'Cape Verdean escudo' }.freeze,
        'CZK' => { numeric_code: 203, minor_unit: 2, name: 'Czech koruna' }.freeze,
        'DJF' => { numeric_code: 262, minor_unit: 0, name: 'Djiboutian franc' }.freeze,
        'DKK' => { numeric_code: 208, minor_unit: 2, name: 'Danish krone' }.freeze,
        'DOP' => { numeric_code: 214, minor_unit: 2, name: 'Dominican peso' }.freeze,
        'DZD' => { numeric_code: 12, minor_unit: 2, name: 'Algerian dinar' }.freeze,
        'EGP' => { numeric_code: 818, minor_unit: 2, name: 'Egyptian pound' }.freeze,
        'ERN' => { numeric_code: 232, minor_unit: 2, name: 'Eritrean nakfa' }.freeze,
        'ETB' => { numeric_code: 230, minor_unit: 2, name: 'Ethiopian birr' }.freeze,
        'EUR' => { numeric_code: 978, minor_unit: 2, name: 'Euro' }.freeze,
        'FJD' => { numeric_code: 242, minor_unit: 2, name: 'Fiji dollar' }.freeze,
        'FKP' => { numeric_code: 238, minor_unit: 2, name: 'Falkland Islands pound' }.freeze,
        'GBP' => { numeric_code: 826, minor_unit: 2, name: 'Pound sterling' }.freeze,
        'GEL' => { numeric_code: 981, minor_unit: 2, name: 'Georgian lari' }.freeze,
        'GHS' => { numeric_code: 936, minor_unit: 2, name: 'Ghanaian cedi' }.freeze,
        'GIP' => { numeric_code: 292, minor_unit: 2, name: 'Gibraltar pound' }.freeze,
        'GMD' => { numeric_code: 270, minor_unit: 2, name: 'Gambian dalasi' }.freeze,
        'GNF' => { numeric_code: 324, minor_unit: 0, name: 'Guinean franc' }.freeze,
        'GTQ' => { numeric_code: 320, minor_unit: 2, name: 'Guatemalan quetzal' }.freeze,
        'GYD' => { numeric_code: 328, minor_unit: 2, name: 'Guyanese dollar' }.freeze,
        'HKD' => { numeric_code: 344, minor_unit: 2, name: 'Hong Kong dollar' }.freeze,
        'HNL' => { numeric_code: 340, minor_unit: 2, name: 'Honduran lempira' }.freeze,
        'HRK' => { numeric_code: 191, minor_unit: 2, name: 'Croatian kuna' }.freeze,
        'HTG' => { numeric_code: 332, minor_unit: 2, name: 'Haitian gourde' }.freeze,
        'HUF' => { numeric_code: 348, minor_unit: 2, name: 'Hungarian forint' }.freeze,
        'IDR' => { numeric_code: 360, minor_unit: 2, name: 'Indonesian rupiah' }.freeze,
        'ILS' => { numeric_code: 376, minor_unit: 2, name: 'Israeli new shekel' }.freeze,
        'INR' => { numeric_code: 356, minor_unit: 2, name: 'Indian rupee' }.freeze,
        'IQD' => { numeric_code: 368, minor_unit: 3, name: 'Iraqi dinar' }.freeze,
        'IRR' => { numeric_code: 364, minor_unit: 2, name: 'Iranian rial' }.freeze,
        'ISK' => { numeric_code: 352, minor_unit: 0, name: 'Icelandic króna (plural: krónur)' }.freeze,
        'JMD' => { numeric_code: 388, minor_unit: 2, name: 'Jamaican dollar' }.freeze,
        'JOD' => { numeric_code: 400, minor_unit: 3, name: 'Jordanian dinar' }.freeze,
        'JPY' => { numeric_code: 392, minor_unit: 0, name: 'Japanese yen' }.freeze,
        'KES' => { numeric_code: 404, minor_unit: 2, name: 'Kenyan shilling' }.freeze,
        'KGS' => { numeric_code: 417, minor_unit: 2, name: 'Kyrgyzstani som' }.freeze,
        'KHR' => { numeric_code: 116, minor_unit: 2, name: 'Cambodian riel' }.freeze,
        'KMF' => { numeric_code: 174, minor_unit: 0, name: 'Comoro franc' }.freeze,
        'KPW' => { numeric_code: 408, minor_unit: 2, name: 'North Korean won' }.freeze,
        'KRW' => { numeric_code: 410, minor_unit: 0, name: 'South Korean won' }.freeze,
        'KWD' => { numeric_code: 414, minor_unit: 3, name: 'Kuwaiti dinar' }.freeze,
        'KYD' => { numeric_code: 136, minor_unit: 2, name: 'Cayman Islands dollar' }.freeze,
        'KZT' => { numeric_code: 398, minor_unit: 2, name: 'Kazakhstani tenge' }.freeze,
        'LAK' => { numeric_code: 418, minor_unit: 2, name: 'Lao kip' }.freeze,
        'LBP' => { numeric_code: 422, minor_unit: 2, name: 'Lebanese pound' }.freeze,
        'LKR' => { numeric_code: 144, minor_unit: 2, name: 'Sri Lankan rupee' }.freeze,
        'LRD' => { numeric_code: 430, minor_unit: 2, name: 'Liberian dollar' }.freeze,
        'LSL' => { numeric_code: 426, minor_unit: 2, name: 'Lesotho loti' }.freeze,
        'LYD' => { numeric_code: 434, minor_unit: 3, name: 'Libyan dinar' }.freeze,
        'MAD' => { numeric_code: 504, minor_unit: 2, name: 'Moroccan dirham' }.freeze,
        'MDL' => { numeric_code: 498, minor_unit: 2, name: 'Moldovan leu' }.freeze,
        'MGA' => { numeric_code: 969, minor_unit: 2, name: 'Malagasy ariary' }.freeze,
        'MKD' => { numeric_code: 807, minor_unit: 2, name: 'Macedonian denar' }.freeze,
        'MMK' => { numeric_code: 104, minor_unit: 2, name: 'Myanmar kyat' }.freeze,
        'MNT' => { numeric_code: 496, minor_unit: 2, name: 'Mongolian tögrög' }.freeze,
        'MOP' => { numeric_code: 446, minor_unit: 2, name: 'Macanese pataca' }.freeze,
        'MRU' => { numeric_code: 929, minor_unit: 2, name: 'Mauritanian ouguiya' }.freeze,
        'MUR' => { numeric_code: 480, minor_unit: 2, name: 'Mauritian rupee' }.freeze,
        'MVR' => { numeric_code: 462, minor_unit: 2, name: 'Maldivian rufiyaa' }.freeze,
        'MWK' => { numeric_code: 454, minor_unit: 2, name: 'Malawian kwacha' }.freeze,
        'MXN' => { numeric_code: 484, minor_unit: 2, name: 'Mexican peso' }.freeze,
        'MXV' => { numeric_code: 979, minor_unit: 2, name: 'Mexican Unidad de Inversion (UDI) (funds code)' }.freeze,
        'MYR' => { numeric_code: 458, minor_unit: 2, name: 'Malaysian ringgit' }.freeze,
        'MZN' => { numeric_code: 943, minor_unit: 2, name: 'Mozambican metical' }.freeze,
        'NAD' => { numeric_code: 516, minor_unit: 2, name: 'Namibian dollar' }.freeze,
        'NGN' => { numeric_code: 566, minor_unit: 2, name: 'Nigerian naira' }.freeze,
        'NIO' => { numeric_code: 558, minor_unit: 2, name: 'Nicaraguan córdoba' }.freeze,
        'NOK' => { numeric_code: 578, minor_unit: 2, name: 'Norwegian krone' }.freeze,
        'NPR' => { numeric_code: 524, minor_unit: 2, name: 'Nepalese rupee' }.freeze,
        'NZD' => { numeric_code: 554, minor_unit: 2, name: 'New Zealand dollar' }.freeze,
        'OMR' => { numeric_code: 512, minor_unit: 3, name: 'Omani rial' }.freeze,
        'PAB' => { numeric_code: 590, minor_unit: 2, name: 'Panamanian balboa' }.freeze,
        'PEN' => { numeric_code: 604, minor_unit: 2, name: 'Peruvian sol' }.freeze,
        'PGK' => { numeric_code: 598, minor_unit: 2, name: 'Papua New Guinean kina' }.freeze,
        'PHP' => { numeric_code: 608, minor_unit: 2, name: 'Philippine peso' }.freeze,
        'PKR' => { numeric_code: 586, minor_unit: 2, name: 'Pakistani rupee' }.freeze,
        'PLN' => { numeric_code: 985, minor_unit: 2, name: 'Polish złoty' }.freeze,
        'PYG' => { numeric_code: 600, minor_unit: 0, name: 'Paraguayan guaraní' }.freeze,
        'QAR' => { numeric_code: 634, minor_unit: 2, name: 'Qatari riyal' }.freeze,
        'RON' => { numeric_code: 946, minor_unit: 2, name: 'Romanian leu' }.freeze,
        'RSD' => { numeric_code: 941, minor_unit: 2, name: 'Serbian dinar' }.freeze,
        'RUB' => { numeric_code: 643, minor_unit: 2, name: 'Russian ruble' }.freeze,
        'RWF' => { numeric_code: 646, minor_unit: 0, name: 'Rwandan franc' }.freeze,
        'SAR' => { numeric_code: 682, minor_unit: 2, name: 'Saudi riyal' }.freeze,
        'SBD' => { numeric_code: 90, minor_unit: 2, name: 'Solomon Islands dollar' }.freeze,
        'SCR' => { numeric_code: 690, minor_unit: 2, name: 'Seychelles rupee' }.freeze,
        'SDG' => { numeric_code: 938, minor_unit: 2, name: 'Sudanese pound' }.freeze,
        'SEK' => { numeric_code: 752, minor_unit: 2, name: 'Swedish krona (plural: kronor)' }.freeze,
        'SGD' => { numeric_code: 702, minor_unit: 2, name: 'Singapore dollar' }.freeze,
        'SHP' => { numeric_code: 654, minor_unit: 2, name: 'Saint Helena pound' }.freeze,
        'SLL' => { numeric_code: 694, minor_unit: 2, name: 'Sierra Leonean leone' }.freeze,
        'SOS' => { numeric_code: 706, minor_unit: 2, name: 'Somali shilling' }.freeze,
        'SRD' => { numeric_code: 968, minor_unit: 2, name: 'Surinamese dollar' }.freeze,
        'SSP' => { numeric_code: 728, minor_unit: 2, name: 'South Sudanese pound' }.freeze,
        'STN' => { numeric_code: 930, minor_unit: 2, name: 'São Tomé and Príncipe dobra' }.freeze,
        'SVC' => { numeric_code: 222, minor_unit: 2, name: 'Salvadoran colón' }.freeze,
        'SYP' => { numeric_code: 760, minor_unit: 2, name: 'Syrian pound' }.freeze,
        'SZL' => { numeric_code: 748, minor_unit: 2, name: 'Swazi lilangeni' }.freeze,
        'THB' => { numeric_code: 764, minor_unit: 2, name: 'Thai baht' }.freeze,
        'TJS' => { numeric_code: 972, minor_unit: 2, name: 'Tajikistani somoni' }.freeze,
        'TMT' => { numeric_code: 934, minor_unit: 2, name: 'Turkmenistan manat' }.freeze,
        'TND' => { numeric_code: 788, minor_unit: 3, name: 'Tunisian dinar' }.freeze,
        'TOP' => { numeric_code: 776, minor_unit: 2, name: 'Tongan paʻanga' }.freeze,
        'TRY' => { numeric_code: 949, minor_unit: 2, name: 'Turkish lira' }.freeze,
        'TTD' => { numeric_code: 780, minor_unit: 2, name: 'Trinidad and Tobago dollar' }.freeze,
        'TWD' => { numeric_code: 901, minor_unit: 2, name: 'New Taiwan dollar' }.freeze,
        'TZS' => { numeric_code: 834, minor_unit: 2, name: 'Tanzanian shilling' }.freeze,
        'UAH' => { numeric_code: 980, minor_unit: 2, name: 'Ukrainian hryvnia' }.freeze,
        'UGX' => { numeric_code: 800, minor_unit: 0, name: 'Ugandan shilling' }.freeze,
        'USD' => { numeric_code: 840, minor_unit: 2, name: 'United States dollar' }.freeze,
        'USN' => { numeric_code: 997, minor_unit: 2, name: 'United States dollar (next day) (funds code)' }.freeze,
        'UYI' => { numeric_code: 940, minor_unit: 0, name: 'Uruguay Peso en Unidades Indexadas (URUIURUI) (funds code)' }.freeze,
        'UYU' => { numeric_code: 858, minor_unit: 2, name: 'Uruguayan peso' }.freeze,
        'UYW' => { numeric_code: 927, minor_unit: 4, name: 'Unidad previsional' }.freeze,
        'UZS' => { numeric_code: 860, minor_unit: 2, name: 'Uzbekistan som' }.freeze,
        'VED' => { numeric_code: 926, minor_unit: 2, name: 'Venezuelan bolívar digital' }.freeze,
        'VES' => { numeric_code: 928, minor_unit: 2, name: 'Venezuelan bolívar soberano' }.freeze,
        'VND' => { numeric_code: 704, minor_unit: 0, name: 'Vietnamese đồng' }.freeze,
        'VUV' => { numeric_code: 548, minor_unit: 0, name: 'Vanuatu vatu' }.freeze,
        'WST' => { numeric_code: 882, minor_unit: 2, name: 'Samoan tala' }.freeze,
        'XAF' => { numeric_code: 950, minor_unit: 0, name: 'CFA franc BEAC' }.freeze,
        'XAG' => { numeric_code: 961, minor_unit: nil, name: 'Silver (one troy ounce)' }.freeze,
        'XAU' => { numeric_code: 959, minor_unit: nil, name: 'Gold (one troy ounce)' }.freeze,
        'XBA' => { numeric_code: 955, minor_unit: nil, name: 'European Composite Unit (EURCO) (bond market unit)' }.freeze,
        'XBB' => { numeric_code: 956, minor_unit: nil, name: 'European Monetary Unit (E.M.U.-6) (bond market unit)' }.freeze,
        'XBC' => { numeric_code: 957, minor_unit: nil, name: 'European Unit of Account 9 (E.U.A.-9) (bond market unit)' }.freeze,
        'XBD' => { numeric_code: 958, minor_unit: nil, name: 'European Unit of Account 17 (E.U.A.-17) (bond market unit)' }.freeze,
        'XCD' => { numeric_code: 951, minor_unit: 2, name: 'East Caribbean dollar' }.freeze,
        'XDR' => { numeric_code: 960, minor_unit: nil, name: 'Special drawing rights' }.freeze,
        'XOF' => { numeric_code: 952, minor_unit: 0, name: 'CFA franc BCEAO' }.freeze,
        'XPD' => { numeric_code: 964, minor_unit: nil, name: 'Palladium (one troy ounce)' }.freeze,
        'XPF' => { numeric_code: 953, minor_unit: 0, name: 'CFP franc (franc Pacifique)' }.freeze,
        'XPT' => { numeric_code: 962, minor_unit: nil, name: 'Platinum (one troy ounce)' }.freeze,
        'XSU' => { numeric_code: 994, minor_unit: nil, name: 'SUCRE' }.freeze,
        'XTS' => { numeric_code: 963, minor_unit: nil, name: 'Code reserved for testing' }.freeze,
        'XUA' => { numeric_code: 965, minor_unit: nil, name: 'ADB Unit of Account' }.freeze,
        'XXX' => { numeric_code: 999, minor_unit: nil, name: 'No currency' }.freeze,
        'YER' => { numeric_code: 886, minor_unit: 2, name: 'Yemeni rial' }.freeze,
        'ZAR' => { numeric_code: 710, minor_unit: 2, name: 'South African rand' }.freeze,
        'ZMW' => { numeric_code: 967, minor_unit: 2, name: 'Zambian kwacha' }.freeze,
        'ZWL' => { numeric_code: 932, minor_unit: 2, name: 'Zimbabwean dollar' }.freeze
      }.freeze
    end
  end
end
