import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:izlyclient/izlyclient.dart';
import 'package:onyx/core/cache_service.dart';
import 'package:onyx/screens/izly/izly_export.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IzlySettingsWidget extends StatelessWidget {
  const IzlySettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: MediaQuery.of(context).size.width,
      color: const Color(0xffbf616a),
      textColor: Colors.white70,
      child: Text(AppLocalizations.of(context).logoutIzly),
      onPressed: () {
        CacheService.reset<IzlyCredential>();
        context.read<IzlyCubit>().disconnect();
      },
    );
  }
}
