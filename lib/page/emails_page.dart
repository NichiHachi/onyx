import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oloid2/states/authentification/authentification_bloc.dart';
import 'package:oloid2/states/email/email_bloc.dart';

import '../widget/emails/email.dart';
import '../widget/emails/email_header.dart';

class EmailsPage extends StatelessWidget {
  final ScrollController scrollController = ScrollController();

  EmailsPage({
    Key? key,
  }) : super(key: key);

  void jumpToTop() {
    scrollController.animateTo(
      0,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmailBloc(
          username: context.read<AuthentificationBloc>().usename,
          password: context.read<AuthentificationBloc>().password),
      child: BlocBuilder<EmailBloc, EmailState>(
        builder: (context, state) {
          if (state is EmailInitial) {
            context.read<EmailBloc>().add(EmailLoad());
          }
          if (kDebugMode) {
            print(state);
          }
          return Container(
              color: Theme.of(context).backgroundColor,
              child: RefreshIndicator(
                color: Theme.of(context).primaryColor,
                child: ListView.custom(
                  controller: scrollController,
                  childrenDelegate:
                      SliverChildBuilderDelegate((context, index) {
                    if (index == 0) {
                      return EmailHeader(
                        createEmail: () {},
                        searchEmail: (String query) async {},
                      );
                    } else if (index <
                        context.read<EmailBloc>().emails.length + 1) {
                      return Email(email: context.read<EmailBloc>().emails[index - 1]);
                    }
                    return null;
                  }),
                ),
                onRefresh: () async {},
              ));
        },
      ),
    );
  }
}
