import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/provider/general_provider.dart';
import 'package:provider/provider.dart';

import '../../theme/theme_manager.dart';

class StaticAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight * 1.2);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    ThemeData _theme = Theme.of(context);
    final _themeModel = Provider.of<ThemeModel>(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: _size.width*0.17,
      leading: Builder(
        builder: (context) => IconButton(
          icon: CircleAvatar(
            backgroundColor: _theme.primaryColor,
            child: Text(
              Provider.of<GeneralProvider>(context).actualAccount.name[0].toUpperCase(),
              style: TextStyle(
                color: _theme.shadowColor,
                fontSize: _size.height*0.025,
                fontWeight: FontWeight.bold

              ),
            ),
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        Switch(
          activeColor: _theme.primaryColor,
          inactiveThumbColor: _theme.primaryColor,
          focusColor: _theme.secondaryHeaderColor,

          value: _themeModel.isDark,
          onChanged: (value) {
            _themeModel.toggleTheme();
          },
        ),
      ],
      toolbarHeight: _size.height, // Increase this value as needed
    );
  }
}
