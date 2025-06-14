import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:posha/presentation/pages/details/details_page.dart';
import 'package:posha/presentation/pages/home/favorites_page.dart';
import 'package:posha/presentation/pages/home/history_page.dart';
import 'data/models/pet_model.dart';
import 'data/local/pet_storage_helper.dart';
import 'data/repositories/pet_repository.dart';
import 'logic/bloc/pet_bloc.dart';
import 'logic/bloc/pet_event.dart';
import 'presentation/pages/home/main_app_page.dart';
import 'presentation/pages/home/home_page.dart';
import 'services/api_service.dart';
import 'routes/app_routes.dart';
import 'package:posha/data/models/pet_model.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(PetAdapter());

  if (!Hive.isBoxOpen('pets')) {
    await Hive.openBox<Pet>('pets');
    await Hive.openBox('favorites');
  }
  await PetStorageHelper.init();

  runApp(const PetAdoptionApp());
}

class PetAdoptionApp extends StatelessWidget {
  const PetAdoptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => PetRepository(apiService: ApiService()),
      child: BlocProvider(
        create: (context) => PetBloc(repository: context.read<PetRepository>())
          ..add(LoadPetsEvent()),
        child: MaterialApp(
          title: 'Pet Adoption App',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          initialRoute: AppRoutes.mainApp,
          routes: {
            AppRoutes.mainApp: (context) => const MainAppScreen(),
            AppRoutes.home: (context) => const HomePage(),
            AppRoutes.favorites: (context) => const FavoritesPage(),
            AppRoutes.history: (context) => const HistoryPage(),
            AppRoutes.petDetails: (context) {
              final pet = ModalRoute.of(context)!.settings.arguments as Pet;
              return DetailsPage(pet: pet);
            },
          },
        ),
      ),
    );
  }
}
