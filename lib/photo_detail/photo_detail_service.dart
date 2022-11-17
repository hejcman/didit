import '../storage/schema.dart';

enum Menu { itemOne, itemTwo, itemThree }

String mapToText(Menu menuItem) {
  switch (menuItem) {
    case Menu.itemOne:
      return "1";
    case Menu.itemTwo:
      return "7";
    case Menu.itemThree:
      return "30";
  }
}

Menu mapToMenu(LifetimeTag tag) {
  switch (tag) {
    case LifetimeTag.oneDay:
      return Menu.itemOne;
    case LifetimeTag.sevenDays:
      return Menu.itemTwo;
    case LifetimeTag.thirtyDays:
      return Menu.itemThree;
  }
}

LifetimeTag mapToTag(Menu menuItem) {
  switch (menuItem) {
    case Menu.itemOne:
      return LifetimeTag.oneDay;
    case Menu.itemTwo:
      return LifetimeTag.sevenDays;
    case Menu.itemThree:
      return LifetimeTag.thirtyDays;
  }
}
