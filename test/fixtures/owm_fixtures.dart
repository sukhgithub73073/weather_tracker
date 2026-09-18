/// Trimmed OpenWeatherMap responses used across the data-layer tests.
/// Timestamps are for 2025-06-10 in Europe/London (offset +3600).

Map<String, dynamic> currentWeatherJson() => {
      'coord': {'lon': -0.1257, 'lat': 51.5085},
      'weather': [
        {'id': 500, 'main': 'Rain', 'description': 'light rain', 'icon': '10d'}
      ],
      'main': {
        'temp': 18.4,
        'feels_like': 18.1,
        'temp_min': 17.0,
        'temp_max': 19.6,
        'pressure': 1012,
        'humidity': 72,
      },
      'visibility': 10000,
      'wind': {'speed': 4.6, 'deg': 230, 'gust': 8.2},
      'rain': {'1h': 0.4},
      'clouds': {'all': 75},
      'dt': 1749553200, // 2025-06-10 11:00 UTC
      'sys': {'country': 'GB', 'sunrise': 1749527400, 'sunset': 1749586800},
      'timezone': 3600,
      'name': 'London',
    };

/// 3-hour entries spanning two local days.
Map<String, dynamic> forecastJson() {
  Map<String, dynamic> entry(int dt, double temp, double pop, String icon, {double? rain3h}) => {
        'dt': dt,
        'main': {
          'temp': temp,
          'feels_like': temp - 0.5,
          'temp_min': temp - 1,
          'temp_max': temp + 1,
          'pressure': 1010,
          'humidity': 60,
        },
        'weather': [
          {'id': 800, 'main': 'Clear', 'description': 'desc $icon', 'icon': icon}
        ],
        'clouds': {'all': 20},
        'wind': {'speed': 3.0, 'deg': 180},
        'pop': pop,
        if (rain3h != null) 'rain': {'3h': rain3h},
      };

  const dayOne = 1749553200; // 2025-06-10 11:00 UTC = 12:00 local
  const threeHours = 3 * 3600;
  return {
    'city': {
      'name': 'London',
      'country': 'GB',
      'timezone': 3600,
      'sunrise': 1749527400,
      'sunset': 1749586800,
    },
    'list': [
      entry(dayOne, 20, 0.1, '01d'), // 12:00 local – representative
      entry(dayOne + threeHours, 22, 0.3, '02d'), // 15:00
      entry(dayOne + 2 * threeHours, 19, 0.6, '10d', rain3h: 1.2), // 18:00
      entry(dayOne + 3 * threeHours, 15, 0.2, '01n'), // 21:00
      entry(dayOne + 4 * threeHours, 13, 0.0, '01n'), // 00:00 next day
      entry(dayOne + 5 * threeHours, 12, 0.0, '01n'), // 03:00
      entry(dayOne + 8 * threeHours, 24, 0.05, '02d'), // 12:00 next day
    ],
  };
}

Map<String, dynamic> airPollutionJson() => {
      'list': [
        {
          'dt': 1749553200,
          'main': {'aqi': 2},
          'components': {'co': 230.3, 'no2': 12.1, 'o3': 68.7, 'so2': 3.2, 'pm2_5': 8.5, 'pm10': 11.0},
        }
      ],
    };

List<dynamic> geocodeJson() => [
      {'name': 'London', 'lat': 51.5073, 'lon': -0.1277, 'country': 'GB', 'state': 'England'},
      {'name': 'London', 'lat': 42.9834, 'lon': -81.233, 'country': 'CA', 'state': 'Ontario'},
    ];
