import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const HomePage(),
    );
  }
}

enum City { stockholm, paris, tokyo }

typedef WeatherEmoji = IconData;

Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
      const Duration(seconds: 1),
      () => {
            City.stockholm: Icons.snowing,
            City.paris: Icons.railway_alert_rounded,
            City.tokyo: Icons.wind_power,
          }[city]!);
}

// will be changed by the UI
// UI writes to this and reads from this
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);

// UI reads this
final weatherProvider = FutureProvider<WeatherEmoji>(
  (ref) {
    final city = ref.watch(currentCityProvider);
    if (city != null) {
      return getWeather(city);
    } else {
      return Icons.battery_unknown;
    }
  },
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);

    return Scaffold(
      appBar: AppBar(
          // Consumer Widget ağacın tekrar çizilmesini engelleyecek sadece kendi state'inde değişiklik olduğunda çizilecek.
          title: const Text("Weather")),
      body: Column(
        children: [
          currentWeather.when(
            data: (data) => Icon(
              data,
            ),
            error: (_, __) => const Icon(Icons.error),
            loading: () => const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: City.values.length,
            itemBuilder: (context, index) {
              final city = City.values[index];
              final isSelected = city == ref.watch(currentCityProvider);
              return ListTile(
                title: Text(city.toString()),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () {
                  ref.read(currentCityProvider.notifier).state = city;
                },
              );
            },
          ))
        ],
      ),
    );
  }
}
