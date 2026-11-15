import '../../domain/championship/driver.dart';
import '../../domain/championship/session.dart';
import 'championship_data.dart';

class ChampionshipLoadedData {
    const ChampionshipLoadedData({
        required this.championshipData,
        required this.session,
        required this.drivers,
    });

    final ChampionshipData championshipData;
    final Session session;
    final List<Driver> drivers;
}
